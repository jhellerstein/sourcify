require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Single quote strings (\', %q & %w)' do

  %w{~ ` ! @ # $ % ^ & * _ - + = \\ | ; : ' " , . ? /}.map{|w| [w,w] }.concat(
    [%w{( )}, %w{[ ]}, %w({ }), %w{< >}]
  ).each do |q1,q2|
    %w{q w}.each do |t|

      should "handle '%#{t}#{q1}...#{q2}' (wo escape (single))" do
        process(" xx %#{t}#{q1}hello#{q2} ").should.include("%#{t}#{q1}hello#{q2}")
      end

      should "handle '%#{t}#{q1}...#{q2}' (wo escape (multiple))" do
        tokens = process(" xx %#{t}#{q1}hello#{q2} %#{t}#{q1}world#{q2} ")
        tokens.should.include("%#{t}#{q1}hello#{q2}")
        tokens.should.include("%#{t}#{q1}world#{q2}")
      end

      should "handle '%#{t}#{q1}...#{q2}' (w escape (single))" do
        process(" xx %#{t}#{q1}hel\\#{q2}lo#{q2} ").should.include("%#{t}#{q1}hel\\#{q2}lo#{q2}")
      end

      should "handle '%#{t}#{q1}...#{q2}' (w escape (multiple))" do
        process(" xx %#{t}#{q1}h\\#{q2}el\\#{q2}lo#{q2} ").should.include("%#{t}#{q1}h\\#{q2}el\\#{q2}lo#{q2}")
      end

    end
  end

  should "handle '...' (wo escape (single))" do
    process(" xx 'hello' ").should.include("'hello'")
  end

  should "handle '...' (wo escape (multiple))" do
    tokens = process(" xx 'hello' 'world' ")
    tokens.should.include("'hello'")
    tokens.should.include("'world'")
  end

  should "handle '...' (w escape (single))" do
    process(" xx 'hel\\'lo' ").should.include("'hel\\'lo'")
  end

  should "handle '...' (w escape (multiple))" do
    process(" xx 'h\\'el\\'lo' ").should.include("'h\\'el\\'lo'")
  end

end
