require_relative '../helper'

class FlowCounterSimpleOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end
  
  CONFIG = %[
    unit second
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::FlowCounterSimpleOutput, tag).configure(conf)
  end

  def test_configure
    assert_nothing_raised {
      d = create_driver('')
    }
    assert_nothing_raised {
      d = create_driver(CONFIG)
    }
    assert_nothing_raised {
      d = create_driver(CONFIG + %[indicator num])
    }
    assert_nothing_raised {
      d = create_driver(CONFIG + %[indicator byte])
    }
  end

  def test_num
    d1 = create_driver(CONFIG, 'test.tag1')
    d1.run do
      10.times do
        d1.emit({'message'=> 'a' * 100})
        d1.emit({'message'=> 'b' * 100})
        d1.emit({'message'=> 'c' * 100})
      end
    end
    out = capture_log(d1.instance.log) { d1.instance.flush_emit(60) }
    assert( out.include?("count:30"), out )
  end

  def test_byte
    d1 = create_driver(CONFIG + %[indicator byte], 'test.tag1')
    d1.run do
      10.times do
        d1.emit({'message'=> 'a' * 100})
        d1.emit({'message'=> 'b' * 100})
        d1.emit({'message'=> 'c' * 100})
      end
    end
    out = capture_log(d1.instance.log) { d1.instance.flush_emit(60) }
    assert( out.include?("count:3360"), out )
  end

  def test_comment
    d1 = create_driver(CONFIG + %[comment foobar], 'test.tag1')
    d1.run do
      1.times do
        d1.emit({'message'=> 'a' * 100})
        d1.emit({'message'=> 'b' * 100})
        d1.emit({'message'=> 'c' * 100})
      end
    end
    out = capture_log(d1.instance.log) { d1.instance.flush_emit(60) }
    assert( out.include?("comment:foobar"), out )
  end
end
