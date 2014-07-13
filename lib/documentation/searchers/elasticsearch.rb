module Documentation
  module Searchers
    class Elasticsearch < Documentation::Searchers::Abstract
    
      def setup
        require 'elasticsearch'
        @client = ::Elasticsearch::Client.new(options[:client] || {})
      end
      
      def index(page)
        @client.index(:index => index_name, :type => 'page', :id => page.id, :body => page_to_hash(page))
      end
      
      def delete(page)
        @client.delete(:index => index_name, :type => 'page', :id => page.id)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
        false
      end
      
      def reset
        @client.indices.delete(:index => index_name)
      end
      
      def search(query, options = {})
        result = @client.search(:index => index_name, :body => {:query => {:simple_query_string => {:query => query,  :fields => [:title, :content]}}})
        search_result = Documentation::SearchResult.new
        search_result.query       = query
        search_result.time        = result['took']
        search_result.raw_results = result['hits']['hits'].inject(Hash.new) do |hash, hit|
          hash[hit['_id'].to_i] = {:score => hit['_score']}
          hash
        end
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
      
    end
  end
end
