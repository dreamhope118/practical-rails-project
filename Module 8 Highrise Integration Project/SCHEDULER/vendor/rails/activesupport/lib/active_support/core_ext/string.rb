require File.dirname(__FILE__) + '/string/inflections'
require File.dirname(__FILE__) + '/string/conversions'
require File.dirname(__FILE__) + '/string/access'
require File.dirname(__FILE__) + '/string/starts_ends_with'
require File.dirname(__FILE__) + '/string/iterators' unless 'test'.respond_to?(:each_char)
require File.dirname(__FILE__) + '/string/unicode'

class String #:nodoc:
  include ActiveSupport::CoreExtensions::String::Access
  include ActiveSupport::CoreExtensions::String::Conversions
  include ActiveSupport::CoreExtensions::String::Inflections
  include ActiveSupport::CoreExtensions::String::StartsEndsWith
  if defined? ActiveSupport::CoreExtensions::String::Iterators
    include ActiveSupport::CoreExtensions::String::Iterators
  end
  include ActiveSupport::CoreExtensions::String::Unicode
end
