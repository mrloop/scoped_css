# Scoped CSS


## Installation

  1. Add to your Gemfile:
  `gem 'scoped_css'`
  2. Run `bundle install`
  3. Include the helper in your views:
  ```ruby
  module ApplicationHelper
    include ScopedCss::Helper
    # other helpers...
  end 
  ```
  4. Use the helper in templates:
  ```erb
  <% style_string, styles = scoped_css do %>
  <style>
    .header { font-weight: bold; }
    .content { margin: 10px; }
  <style>
  <% end %>

  <h1 class="<%= styles[:header] %>">Title</h1>
  <main class="<%= styles[:content] %>">Content here</main>

  <%= style_string %>
  ```

## Usage with ViewComponent  

_app/components/section_component.rb_
```ruby
class SectionComponent < ViewComponent::Base
end
```

_app/components/section_component.html.erb_
```erb
<% style_string, styles = helpers.scoped_css do %>
<style>
  .section { 
    border: none;
    scroll-snap-align: center;
    color: purple;
  }
  .heading {
    font-size: 2rem;
  }
</style>
<% end %>

<section class="<%= styles[:section] %>">
  <h2 class="<%= styles[:heading] %>">Section</h2>
  <%= content %>
</section>

<%= style_string %>
```

## Attribute Splatting

Sometimes you want to apply html attributes to a component from the parent template.


_app/components/section_component.rb_
```ruby
class SectionComponent < ViewComponent::Base
  def initialize(attributes: {})
    @attributes = attributes
  end
end
```

_app/views/home/index.html.erb_
```erb

<% style_string, styles = scoped_css do %>
<style>
  .section {
    margin: 10px;
  }
  .heading {
    font-size: 3rem;
  }
</style>
<% end %>

<h1 class="<%= styles[:heading] %>">Title</h1>
<%= render SectionComponent.new(attributes: { id: "important-section", class: styles[:section] }) do %>
  <p>Section 1</p>
<% end %>

<%= style_string %>
```

_app/components/section_component.html.erb_
```erb
<% style_string, styles = helpers.scoped_css do %>
<style>
  .section { 
    border: none;
    scroll-snap-align: center;
    color: purple;
  }
  .heading {
    font-size: 2rem;
  }
</style>
<% end %>

<section <%= helpers.splat_attributes(@attributes, styles[:section]) %>>
  <h2 class="<%= styles[:heading] %>">Section</h2>
  <%= content %>
</section>

<%= style_string %>
```

:info: Note that `<section class="<%= styles[:heading] %>" <%= helpers.splat_attributes(@attributes, styles[:section]) %>>` is not used. Instead, the `splat_attributes` helper is used to apply the class attribute to the component. The `splat_attributes` helper takes CSS class names after the attributes argument and concatenates these CSS class names with any class names in the attributes hash.

This will generate the following HTML:

```html
<!-- app/views/home/index.html.erb -->

<h1 class=".atge5q2e-heading">Title</h1>

<!-- app/components/section_component.html.erb -->

<section class="agkd94j4-section atge5q2e-section" id="important-section">
  <h2 class="agkd94j4-heading">
</section>

<section class="agkd94j4-section">
  <h2 class="agkd94j4-heading">
  <p>Section</p>
</section>

<style>
  .agkd94j4-section {
    border: none;
    scroll-snap-align: center;
    color: purple;
  }
  .agkd94j4-heading {
    font-size: 2rem;
  }
</style>

<!-- app/views/home/index.html.erb -->

<style>
  .atge5q2e-section {
    margin: 10px;
  }
  .atge5q2e-heading {
    font-size: 3rem;
  }
</style>

```

### CSS Specificity

In previous examples, we applied the CSS class `.section` to the `<section>` element. It has the property `color: purple;`. But what if we want one instance of the SectionComponent to have a different color? In the parent template we can define a CSS class for the section component with the different color and apply it to the component.

_app/components/section_component.rb_
```ruby
class SectionComponent < ViewComponent::Base
  def initialize(attributes: {})
    @attributes = attributes
  end
end
```

_app/components/section_component.html.erb_
```erb
<% style_string, styles = helpers.scoped_css do %>
<style>
  .section { 
    border: none;
    scroll-snap-align: center;
    color: purple;
  }
  .heading {
    font-size: 2rem;
  }
</style>
<% end %>

<section <%= helpers.splat_attributes(@attributes, styles[:section]) %>>
  <h2 class="<%= styles[:heading] %>">Section</h2>
  <%= content %>
</section>

<%= style_string %>
```

_app/views/home/index.html.erb_
```erb
<% style_string, styles = scoped_css do %>
<style>
  .section {
    margin: 10px;
    color: darkgreen;
  }
  .heading {
    font-size: 3rem;
  }
</style>
<% end %>

<h1 class="<%= styles[:heading] %>">Title</h1>
<%= render SectionComponent.new(attributes: { class: styles[:section] }) do %>
  <p>Section 1</p>
<% end %>

<%= render SectionComponent.new() do %>
  <p>Section 2</p>
<% end %>

<%= style_string %>
```

The reason this works is because the we render the style_string in each template at the bottom of the template. Any nested components style tag will be rendered before the parent style tag. The last declared selector has precedence. And because a scoped CSS class name is passed to the component only that instance of the component will use the new color.  

```html
<!-- app/views/home/index.html.erb -->

<h1 class=".atge5q2e-heading">Title</h1>

<!-- app/components/section_component.html.erb -->

<section class="agkd94j4-section atge5q2e-section">
  <h2 class="agkd94j4-heading">
  <p>Section 1</p>
</section>

<section class="agkd94j4-section atge5q2e-section">
  <h2 class="agkd94j4-heading">
  <p>Section 2</p>
</section>

<style>
  .agkd94j4-section {
    border: none;
    scroll-snap-align: center;
    color: purple;
  }
  .agkd94j4-heading {
    font-size: 2rem;
  }
</style>

<!-- app/views/home/index.html.erb -->

<style>
  .atge5q2e-section {
    margin: 10px;
    color: darkgreen;
  }
  .atge5q2e-heading {
    font-size: 3rem;
  }
</style>
```
