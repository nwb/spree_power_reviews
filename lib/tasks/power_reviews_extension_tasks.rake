require 'pp'
require 'net/ftp'
require 'tempfile'
require 'nokogiri'
require 'rubygems'
require 'zip/zip'


desc "Set the environment variable RAILS_ENV='staging'."
task :staging do
  ENV["RAILS_ENV"] = 'staging'
  Rake::Task[:environment].invoke
end

namespace :spree do
  namespace :extensions do
    namespace :power_reviews do
      desc "Fetch Review Data"

      task :load_data => :environment do |t|
          start_time = Time.now
          report_str = [ "Loading Power Review Data: #{start_time.strftime( "%Y-%m-%d %H:%M:%S" )}"]
          success = true
          report_str << "Loading Data"
          complete, report = load_data( start_time )
          report_str << report
          end_time = Time.now
          report_str << "Finished Loading Power Reviews Data:  #{start_time.strftime( "%Y-%m-%d %H:%M:%S" )}"
          report_str << "Elapsed time: #{(end_time - start_time) rescue 'unknown'} seconds"
          puts report_str
      end

      def load_data  timestamp
        loaded, extracted, report = get_new_data( timestamp )
        pr_dir = File.join( Rails.root, "tmp", "powerreviews" )
        current = File.join( pr_dir,  "pwr" )
        link_source =  File.join( extracted, "pwr" )
        the_directories = ["content", "engine"]
        result = true
        case loaded
        when :complete
          is_linked = true
          load_reviews = true
          
          if File.exist?( current ) && !File.symlink?( current )
            report << "#{current} exists and is not a symlink, deleting"
            remove_entry_secure(current, true)
          elsif File.exist?( current ) && File.symlink?( current )
              report << "Unlinking #{current}"
              File.unlink( current )
          end
          report << "Linking #{link_source} to #{current}"
          File.symlink( link_source, current )
          
          if load_reviews
            # Find the review data
            rds = Dir.glob( File.join( extracted,"**/review_data_summary.xml" ) )
            prods = []
            summary_doc = Nokogiri::XML( open(rds.first) )
            summary_doc.css( "product" ).each do | prod |
              page_id    = prod.css( "pageid" ).inner_text
              if Spree::Product.exists?( page_id )
                product = Spree::Product.find( page_id )
                unless product.review_set
                  product.create_review_set
                  product.save
                  product.reload
                end
                review_set = product.review_set
                thefile =prod.css( 'inlinefile[reviewpage="1"]' ).inner_text || ''
                review_set.inline_path           = "/data/nwbsite/current/tmp/powerreviews/" + thefile unless thefile.blank?
                
                thefile =prod.css( 'inlinefile[questionpage="1"]' ).inner_text || ''
                review_set.qa_inline_path        = "/data/nwbsite/current/tmp/powerreviews/" + thefile unless thefile.blank?
                review_set.full_review_count     = prod.css( "fullreviews" ).inner_text.to_i
                review_set.average_rating        = prod.css( "average_rating_decimal" ).inner_text.to_f
                review_set.bottom_line_yes_votes = prod.css( "bottom_line_yes_votes" ).inner_text.to_i
                review_set.bottom_line_no_votes  = prod.css( "bottom_line_no_votes" ).inner_text.to_i
                review_set.save
                prods << { :store => product.store.code, :permalink => product.permalink}
                report << "Updating reviews for #{product.sku} (#{review_set.full_review_count} reviews)"
              end
            end
            expire_cache( prods )

            # clean up old directories
            excludes = [ ".", "..", 'pwr', File.basename(extracted) ]
            Dir.entries( File.expand_path( File.dirname( extracted ) ) ).reject{ |dir|
              excludes.include?( dir )
            }.each{ |dir|
              report << "Deleting #{File.join( pr_dir, dir)}"
              remove_entry_secure File.join( pr_dir,  dir)
            }
          end
        when :error
          result = false
        end
        [result, report]
      end

      def expire_cache prods
        return unless File.exist?(File.join(Rails.root, "public", "cache"))
        controller = ProductsController.new
        prods.each do |prod|
          Dir.entries(File.join(Rails.root, "public", "cache")).each do |path|
            next if [".", ".."].include?(path)
            begin
              controller.expire_page( "/cache/#{path}/products/#{prod[:permalink]}" )
            rescue Exception => e
              # submerge errors since its possible that the page isn't cached.
            end
            
          end
        end
      end
      
      def get_new_data timestamp

        report = []
        pr_dir  = File.join( Rails.root, "tmp", "powerreviews")
        dest = File.join( pr_dir, timestamp.strftime( "%Y%m%d%H%M%S" ))
        success = :unknown
        begin
          ftp = Net::FTP.new( Spree::PowerReviewsConfiguration.account["default"]["ftp_host"])
          ftp.passive = Spree::PowerReviewsConfiguration.account["default"]["ftp_passive"]
          ftp.login( Spree::PowerReviewsConfiguration.account["default"]["ftp_user"], Spree::PowerReviewsConfiguration.account["default"]["ftp_pass"])

          # we are going to process the 
          if ftp.nlst.include?( Spree::PowerReviewsConfiguration.account["default"]["delete_file"]) || !Spree::PowerReviewsConfiguration.account["default"]["delete"]
            report << "Downloading zipfile #{Spree::PowerReviewsConfiguration.account["default"]["file"] } and extracting to #{dest}"
            tmpzip = Tempfile.new( 'zip' )
            file_count = 0
            ftp.getbinaryfile( Spree::PowerReviewsConfiguration.account["default"]["file"], tmpzip.path)
            Zip::ZipFile.open( tmpzip.path ) { |zip_file|
              zip_file.each { |f|
                file_count +=1
                f_path=File.join(dest, f.name)
                FileUtils.mkdir_p(File.dirname(f_path))
                zip_file.extract(f, f_path) unless File.exist?(f_path)
              }
            }
            report << "Extracted #{file_count} files to #{dest}"
            # verify contents
            if ["content", "engine", "**/review_data_summary.xml" ].inject(true){ |result, the_dir| result && ( Dir.glob( File.join( dest, "pwr",  the_dir ) ).count > 0 ) }
              success = :complete
              if Spree::PowerReviewsConfiguration.account["default"]["delete"]
                report << "Deleting #{Spree::PowerReviewsConfiguration.account["default"]["delete_file"]}"
                ftp.delete(Spree::PowerReviewsConfiguration.account["default"]["delete_file"])
              end
            else
              success = :error
              report << "Zip does not include required files."
            end
          else
            success = :nochange
          end
        rescue Exception => e
          report << e
          success = :error
        ensure
          tmpzip.close if tmpzip
          ftp.close if ftp
        end
        [success,dest,report]
      end
      
      desc "Get the directories setup"
      task :directories => :environment do
        
        pr_dir = File.join( Rails.root, "tmp", 'powerreviews' )
        pub = File.join( Rails.root, "public", 'pwr' )
        dst = File.join( pr_dir, 'pwr' )

        unless File.exists?( dst )
          boot = File.join( pr_dir, "bootstrap", "pwr" )
          mkdir_p boot
          File.symlink( boot, dst )
        end

        raise "#{pub} exists and is not a symlink" if File.exist?( pub ) && !File.symlink?( pub )

        if File.exist?( pub ) && File.symlink?( pub )
          File.unlink( pub )  
        end
        File.symlink( dst, pub )

      end

      desc "Copies public assets of the Power Reviews to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[PowerReviewsExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(PowerReviewsExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p Rails.root + directory
          cp file, Rails.root + path
        end
        # todo create RSA crypto keys.
      end
    end
  end
end
