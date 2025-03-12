# OpenAI Link Analyzer

This is a Discourse plugin that allows users to analyze web links using OpenAI. It fetches content from the specified URL, sends it to OpenAI for analysis, and then creates a new topic in the selected category with a summary of the content.

## Features

- Analyze any web link with OpenAI's powerful language models
- Create concise summaries of web content automatically
- Automatically generate relevant topic titles
- Post the summary to your selected Discourse category
- Configurable OpenAI model selection (GPT-3.5, GPT-4, etc.)
- Admin statistics dashboard to track usage patterns
- Header button for quick access to the analyzer
- Multi-language support (English, German)

## Installation

### Option 1: Standard Installation

Follow the [standard Discourse plugin installation procedure](https://meta.discourse.org/t/install-plugins-in-discourse/19157):

```sh
cd /var/discourse
git clone https://github.com/vitosturm/openai-link-analyzer.git plugins/openai-link-analyzer
./launcher rebuild app
```

### Option 2: Docker Installation (app.yml)

Add the plugin to your `app.yml` file:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/vitosturm/openai-link-analyzer.git
```

Then rebuild your container:

```sh
./launcher rebuild app
```

## Configuration

After installation, visit your admin settings at `/admin/site_settings` and search for "openai" to find the plugin settings:

1. Enable the plugin by setting `openai_link_analyzer_enabled` to `true`
2. Enter your OpenAI API key in the `openai_api_key` field
3. Select the OpenAI model you want to use (default is `gpt-4`)

You can test your API connection in the admin panel at `/admin/plugins/openai-link-analyzer`.

## Usage

### For Regular Users

1. Navigate to your user page at `/u/username/openai-link-analyzer`
2. Enter a URL in the input field
3. Select a category for the new topic
4. Click "Analyze and Create Topic"
5. A new topic will be created with a summary of the content

You can also access the analyzer quickly by clicking the magic wand icon in the header.

### For Administrators

1. Navigate to `/admin/plugins/openai-link-analyzer`
2. View usage statistics
3. Test the OpenAI API connection
4. Clear statistics if needed

## How It Works

1. The plugin fetches the content from the specified URL
2. It uses Nokogiri to extract relevant text content from the HTML
3. The content is sent to OpenAI API for analysis
4. OpenAI generates a concise summary and suggests a title
5. The plugin creates a new topic in the selected category with the summary and a link to the original URL

## Development

### Running Tests

```sh
# For frontend tests
bin/rails plugin:qunit['openai-link-analyzer']

# For backend tests (if available)
LOAD_PLUGINS=1 bin/rails plugin:spec['openai-link-analyzer']
```

### File Structure

- `plugin.rb` - Main plugin file
- `app/controllers/` - Backend controllers
- `lib/openai_link_analyzer/` - Core functionality
- `assets/javascripts/` - Frontend code
- `config/locales/` - Translation files
- `test/` - Acceptance tests

## License

MIT

## About

This plugin was created to help Discourse users quickly analyze web content and create discussion topics with meaningful summaries. It's perfect for research, news aggregation, or keeping track of interesting articles.

## Feedback & Contribution

If you have any suggestions or issues, please open an issue on the GitHub repository. Contributions are welcome!

### Contributors

- [vitosturm](https://github.com/vitosturm) - Creator and maintainer
