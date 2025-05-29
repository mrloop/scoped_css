require "minitest/autorun"
require "scoped_css"
require "ostruct"

# Mock Rails.env for testing
module Rails
  def self.env
    OpenStruct.new(local?: false)
  end
end

class TestScopedCss < Minitest::Test
  class TestHelper
    include ScopedCss::Helper

    def capture(&block)
      yield
    end
  end

  def setup
    @helper = TestHelper.new
  end

  PREFIX_REGEX = /a[0-9a-f]{7}/

  def test_scoped_css
    css = ".header { font-weight: bold; }"

    prefixed_css, styles, prefix = @helper.scoped_css do
      css
    end

    assert_match PREFIX_REGEX, prefix
    assert_equal ".#{prefix}-header { font-weight: bold; }", prefixed_css
    assert_equal "#{prefix}-header", styles[:header]
  end

  def test_scoped_css_in_template
    css = ".header { font-weight: bold; } .content { margin: 10px; }"

    prefixed_css, styles = @helper.scoped_css do
      css
    end

    # Simulate template usage
    template_output = "<style>#{prefixed_css}</style>"
    template_output += "<div class='#{styles[:header]}'>Title</div>"
    template_output += "<div class='#{styles[:content]}'>Content here</div>"

    prefix = "a#{Digest::SHA256.hexdigest(css)}"[0,8]
    assert_includes template_output, "<style>.#{prefix}-header"
    assert_includes template_output, "class='#{prefix}-header'"
    assert_includes template_output, "class='#{prefix}-content'"
  end

  def test_multiple_calls_with_same_content
    css = ".box { border: 1px solid black; }"

    # First call should generate the prefixed CSS
    prefixed_css1, styles1 = @helper.scoped_css do
      css
    end

    # Second call with same content should return empty CSS but same mapping
    prefixed_css2, styles2 = @helper.scoped_css do
      css
    end

    assert_equal styles1, styles2
    assert_equal "", prefixed_css2
  end
end
