require_relative "version"
require "digest/sha2"
require "erb"

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

    # Helper to take attribute hashes (or strings for classes) and format them
    # into a string suitable for direct HTML attribute "splatting".
    #
    # Example usage in ERB:
    # <section <%= splat_attributes(@attributes, styles[:section]) %>>
    #   <%= content %>
    # </section>
    #
    # @param args [Array<Hash, String>] One or more attribute hashes or class strings
    # @return [String] A string of HTML attributes (e.g., 'class="foo bar" id="my-id"')
    def splat_attributes(*args)
      combined_attributes = merge_classes(*args)

      # Convert the combined hash into an HTML attribute string
      result = combined_attributes.map do |key, value|
        html_key = key.to_s.dasherize
        escaped_value = ERB::Util.html_escape(value.to_s)

        # Handle boolean attributes (e.g., 'disabled' instead of 'disabled="true"')
        if value.is_a?(TrueClass) && !html_key.empty?
          html_key
        elsif value.is_a?(FalseClass)
          # Don't render attributes that are explicitly false
          nil
        elsif !escaped_value.empty?
          "#{html_key}=\"#{escaped_value}\""
        else
          nil # Don't render attributes with empty values
        end
      end.compact.join(" ").strip

      result.respond_to?(:html_safe) ? result.html_safe : result
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

    def merge_classes(attributes, *css_classes)
      merged_attributes = attributes.dup

      css_class_string = css_classes.compact.join(" ").strip

      if merged_attributes[:class].nil? || merged_attributes[:class].empty?
        merged_attributes[:class] = css_class_string
      else
        merged_attributes[:class] = "#{css_class_string} #{merged_attributes[:class]}".strip
      end

      merged_attributes
    end
  end
end
