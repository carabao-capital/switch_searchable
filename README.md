# SwitchSearchable

Manages multiple search engines in your Rails app. Supported are - PGSearch, AlgoliaSearch and Elasticsearch.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'switch_searchable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_searchable

## Usage

***Make sure you have setup services with Algolia, Elasticsearch. If you are using PGSearch nothing needs to be setup.***

In your ENV - say for example you have Algolia, Elasticsearch and PGSearch setup at the same time:

```
ALGOLIA_APP_ID="lasdfu0as98fusaoij"
ALGOLIA_API_KEY="doasf0a8uf3098ufwo9fjoiajfaldsj"
ALGOLIA_ENVIRONMENT="staging"
ELASTICSEARCH_HOST="196.223.442.112"
SEARCH_ENGINE = "Postgres"
```

`SEARCH_ENGINE` is set to `"PGSearch"`. This means that you have PGSearch activated while the rest are not.

To activate Elasticsearch:

```
SEARCH_ENGINE = "Elasticsearch"
```

To activate Algolia:

```
SEARCH_ENGINE = "Algolia"
```

In your `config/initializers/switch_searchable.rb` file:

```
if ENV["SEARCH_ENGINE"] == "Algolia"

  AlgoliaSearch.configuration = {
    application_id: ENV["ALGOLIA_APP_ID"],
    api_key: ENV["ALGOLIA_API_KEY"],
  }

elsif ENV["SEARCH_ENGINE"] == "Elasticsearch"

  config = {
    host: ENV["ELASTICSEARCH_HOST"],
    transport_options: {
      request: {
        timeout: 5,
      },
    },
  }

  if File.exists?("config/elasticsearch.yml")
    yml = ERB.new(File.new("config/elasticsearch.yml").read)
    config.merge!(YAML.load(yml.result)).deep_symbolize_keys
  end

  Elasticsearch::Model.client = Elasticsearch::Client.new(config)
end
```

In your AR model:

```ruby
class Lead < ActiveRecord::Base
  include SwitchSearchable::Searchable

  searchable_attributes(
    :company_name,
    :first_name,
    :last_name,
    :email,
    {phones: [:number]}
  )

  has_may :phones
end
```

To create an index, run:

```
Lead.reindex!
```

After that, you can now search:
```
Lead.search("Neil the man")
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
