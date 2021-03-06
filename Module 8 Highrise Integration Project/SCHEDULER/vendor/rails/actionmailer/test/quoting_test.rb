require "#{File.dirname(__FILE__)}/abstract_unit"
require 'tmail'
require 'tempfile'

class QuotingTest < Test::Unit::TestCase
  def test_quote_multibyte_chars
    original = "\303\246 \303\270 and \303\245"

    result = execute_in_sandbox(<<-CODE)
      $:.unshift(File.dirname(__FILE__) + "/../lib/")
      $KCODE = 'u'
      require 'jcode'
      require 'action_mailer/quoting'
      include ActionMailer::Quoting
      quoted_printable(#{original.inspect}, "UTF-8")
    CODE

    unquoted = TMail::Unquoter.unquote_and_convert_to(result, nil)
    assert_equal unquoted, original
  end

  # test an email that has been created using \r\n newlines, instead of
  # \n newlines.
  def test_email_quoted_with_0d0a
    mail = TMail::Mail.parse(IO.read("#{File.dirname(__FILE__)}/fixtures/raw_email_quoted_with_0d0a"))
    assert_match %r{Elapsed time}, mail.body
  end

  def test_email_with_partially_quoted_subject
    mail = TMail::Mail.parse(IO.read("#{File.dirname(__FILE__)}/fixtures/raw_email_with_partially_quoted_subject"))
    assert_equal "Re: Test: \"\346\274\242\345\255\227\" mid \"\346\274\242\345\255\227\" tail", mail.subject
  end
  
  def test_rb_decode
    encoded, decoded = expected_base64_strings
    assert_equal decoded, TMail::Base64.rb_decode(encoded)
  end
  
  def test_rb_encode
    encoded, decoded = expected_base64_strings
    assert_equal encoded.length, TMail::Base64.rb_encode(decoded).length
  end
  
  def test_rb_decode_should_match_c_decode_if_available
    encoded, decoded = expected_base64_strings
    
    begin
      require 'tmail/base64.so'
      assert_equal TMail::Base64.rb_decode(encoded), TMail::Base64.c_decode(encoded)
    rescue LoadError
      # No .so
    end
  end
  
  def test_rb_encode_should_match_c_encode_if_available
    encoded, decoded = expected_base64_strings
    
    begin
      require 'tmail/base64.so'
      assert_equal TMail::Base64.rb_encode(decoded), TMail::Base64.c_encode(decoded)
    rescue LoadError
      # No .so
    end
  end

  private
    
    # This whole thing *could* be much simpler, but I don't think Tempfile,
    # popen and others exist on all platforms (like Windows).
    def execute_in_sandbox(code)
      test_name = "#{File.dirname(__FILE__)}/am-quoting-test.#{$$}.rb"
      res_name = "#{File.dirname(__FILE__)}/am-quoting-test.#{$$}.out"

      File.open(test_name, "w+") do |file|
        file.write(<<-CODE)
          block = Proc.new do
            #{code}
          end
          puts block.call
        CODE
      end

      system("ruby #{test_name} > #{res_name}") or raise "could not run test in sandbox"
      File.read(res_name).chomp
    ensure
      File.delete(test_name) rescue nil
      File.delete(res_name) rescue nil
    end
    
    def expected_base64_strings
      [ File.read("#{File.dirname(__FILE__)}/fixtures/raw_base64_encoded_string"), File.read("#{File.dirname(__FILE__)}/fixtures/raw_base64_decoded_string") ]
    end
end
