module Documentation
  module Searchers
    class Elasticsearch < Documentation::Searchers::Abstract
    
      def setup
        require 'elasticsearch'
      end
      
      def index(page)
        client.index(:index => index_name, :type => 'page', :id => page.id, :body => page_to_hash(page))
      end
      
      def delete(page)
        client.delete(:index => index_name, :type => 'page', :id => page.id)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
        false
      end
      
      def reset
        client.indices.delete(:index => index_name)
      end
      
      def search(query, options = {})
        # Default options
        options[:page]      ||= 1
        options[:per_page]  ||= 15
        
        # Prepare our query
        body = {
          :query => {
            :simple_query_string => {:query => query,  :fields => [:title, :content]}
          }
        }
        # Get the total number of results
        count = client.count(:index => index_name, :body => body)

        # Get some actual results for the requested page
        result = client.search(:index => index_name, :body => body.merge({
          :from => (options[:page].to_i - 1) * options[:per_page].to_i,
          :size => options[:per_page].to_i,
          :highlight => {
            :pre_tags => ["{{{"],
            :post_tags => ["}}}"],
            :fields => {:content => {}}
          }
        }))
        
        # Create a result object to be returned
        search_result                 = Documentation::SearchResult.new
        search_result.page            = options[:page].to_i
        search_result.per_page        = options[:per_page].to_i
        search_result.total_results   = count['count'].to_i
        search_result.query           = query
        search_result.time            = result['took']
        search_result.raw_results     = result['hits']['hits'].inject(Hash.new) do |hash, hit|
          hash[hit['_id'].to_i] = {
            :score => hit['_score'],
            :highlights => hit['highlight'] && hit['highlight']['content']
          }
          hash
        end
        
        # Return it
        search_result
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
        Documentation::SearchResult.new
      end
      
      private
      
      def index_name
        options[:index_name] || 'pages'
      end
      
      def page_to_hash(page)
        {
          :id => page.id,
          :title => page.title,
          :permalink => page.permalink,
          :full_permalink => page.full_permalink,
          :content => page.content,
          :created_at => page.created_at,
          :updated_at => page.updated_at
        }
      end
      
      private
      
      def client
        @client ||= ::Elasticsearch::Client.new(options[:client] || {})
      end
      
    end
  end
end
