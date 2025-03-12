# OpenAI Link Analyzer

A Discourse plugin that uses OpenAI to analyze web links, create summaries, and post them to your forum.

## Features

- Analyze web links using OpenAI's powerful language models
- Generate concise summaries of web content
- Create topics with the analyzed content in selected categories
- Track statistics on link analysis usage
- Admin interface for monitoring and configuration

## Requirements

- Discourse version 2.7.0 or higher
- An OpenAI API key

## Installation

Follow the [standard Discourse plugin installation instructions](https://meta.discourse.org/t/install-plugins-in-discourse/19157):

1. Add the plugin to your container's `app.yml` file:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/yourusername/discourse-openai-link-analyzer.git
```

2. Rebuild your container:

```bash
cd /var/discourse
./launcher rebuild app
```

## Configuration

1. Go to Admin > Plugins and enable the "OpenAI Link Analyzer" plugin
2. Go to Admin > Settings > Plugins and configure:
   - `openai_link_analyzer_enabled`: Enable or disable the plugin
   - `openai_api_key`: Your OpenAI API key
   - `openai_model`: The OpenAI model to use for analysis (gpt-3.5-turbo, gpt-4, or gpt-4-turbo)

## Usage

### For Users

1. Navigate to your user profile page
2. Click on the "OpenAI Link Analyzer" tab
3. Enter a URL to analyze
4. Select a category for the resulting topic
5. Click "Analyze" to process the link
6. View the summary and click "View Topic" to see the created topic

### For Admins

1. Go to Admin > Plugins > OpenAI Link Analyzer
2. View usage statistics
3. Test the OpenAI API connection
4. Clear statistics if needed

## Development

### Prerequisites

- [Discourse Development Environment](https://meta.discourse.org/t/beginners-guide-to-install-discourse-for-development-using-docker/102009)

### Setup for Development

1. Clone the repository to your Discourse plugins directory:

```bash
cd /path/to/discourse/plugins
git clone https://github.com/yourusername/discourse-openai-link-analyzer.git
```

2. Start your Discourse development server

### Running Tests

```bash
cd /path/to/discourse
LOAD_PLUGINS=1 bundle exec rspec plugins/openai-link-analyzer/spec
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT

## Support

For support, please [open an issue](https://github.com/yourusername/discourse-openai-link-analyzer/issues) on GitHub.
