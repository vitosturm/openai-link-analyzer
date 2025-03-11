# OpenAI Link Analyzer

This is a Discourse plugin that allows users to analyze web links using OpenAI. It fetches content from the specified URL, sends it to OpenAI for analysis, and then creates a new topic in the selected category with a summary of the content.

## Features

- Analyze any web link with OpenAI
- Create a summary of the web content
- Automatically generate a topic title
- Post the summary to a selected category
- Configurable OpenAI model selection

## Installation

Follow the [standard Discourse plugin installation procedure](https://meta.discourse.org/t/install-plugins-in-discourse/19157):

```sh
cd /var/discourse
git clone https://github.com/yourusername/openai-link-analyzer.git plugins/openai-link-analyzer
./launcher rebuild app
```

## Configuration

After installation, visit your admin settings at `/admin/site_settings` and search for "openai" to find the plugin settings:

1. Enable the plugin by setting `openai_link_analyzer_enabled` to `true`
2. Enter your OpenAI API key in the `openai_api_key` field
3. Select the OpenAI model you want to use (default is `gpt-4`)

## Usage

1. Navigate to your user page at `/u/username/openai-link-analyzer`
2. Enter a URL in the input field
3. Select a category for the new topic
4. Click "Analyze and Create Topic"
5. A new topic will be created with a summary of the content

## Development

1. Clone the repository to your plugins directory
2. Make your changes
3. Restart the Discourse server

## License

MIT

## About

This plugin was created to help Discourse users quickly analyze web content and create discussion topics with meaningful summaries.

## Feedback

If you have any suggestions or issues, please open an issue on the GitHub repository.
