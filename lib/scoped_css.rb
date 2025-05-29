require_relative "version"
require "digest/sha2"

module ScopedCss
  module Helper
    def scoped_css(&css_block)
      @per_template_outputs ||= Hash.new

      css_block_content = ""
      if block_given?
        css_block_content = capture(&css_block)
      end

      prefix = "a#{Digest::SHA256.hexdigest(css_block_content)}"[0,8]

      styles = Hash.new
      prefixed_css_block_content = Rails.env.local? ? ' <!-- previously output --> ' : ''

      if @per_template_outputs.has_key?(prefix)
        styles = @per_template_outputs[prefix]
      else
       prefixed_css_block_content, styles =   prefix_css_classes(css_block_content, prefix)
        @per_template_outputs[prefix] = styles
      end

      result = prefixed_css_block_content.respond_to?(:html_safe) ? prefixed_css_block_content.html_safe : prefixed_css_block_content
      return [result, styles, prefix]
    end

    private

    def prefix_css_classes(css_string, prefix)
      updated_css_string = css_string.dup
      class_name_map = {}
      class_selector_regex = /\.([_a-zA-Z][_a-zA-Z0-9-]*)/

      updated_css_string.gsub!(class_selector_regex) do |full_match|
        original_class_name = Regexp.last_match[1]
        prefixed_class_name = "#{prefix}-#{original_class_name}"
        class_name_map[original_class_name.to_sym] = prefixed_class_name
        ".#{prefixed_class_name}"
      end

      return updated_css_string, class_name_map
    end
  end
end
