require "rspec"
require 'mini_kanren'
require 'mini_kanren/core'

describe "Core" do
  it "all()" do
    MiniKanren.exec do
      q = fresh
      run(q,eq(true, q)).should == [true]
      run(q, fail).should == []
      run(q, eq(true, q)).should == [true]
      run(q, all(fail, eq(true, q))).should == []
      run(q, all(succeed, eq(true, q))).should == [true]
      run(q, all(succeed, eq(:corn, q))).should == [:corn]
      run(q, all(fail, eq(:corn, q))).should == []
      run(q, all(succeed, eq(false, q))).should == [false]

      x = fresh
      run(q, eq(true,q))
      run(q, all(eq(true, x), eq(true, q))).should == [true]
      run(q, all(eq(x, true), eq(true, q))).should == [true]
      run(q, succeed).should == ["_.0"]
      run(q, succeed).should == ["_.0"]

      x, y = fresh(2)
      run(q, eq([x, y], q)).should == [["_.0", "_.1"]]
      t, u = fresh(2)
      run(q, eq([t, u], q)).should == [["_.0", "_.1"]]

      x = fresh
      y = x
      x = fresh
      run(q, eq([y, x, y], q)).should == [["_.0", "_.1", "_.0"]]

      run(q, all(eq(false, q), eq(true, q))).should == []
      run(q, all(eq(false, q), eq(false, q))).should == [false]

      x = q
      run(q, eq(true, x)).should == [true]

      x = fresh
      run(q, eq(x, q)).should == ["_.0"]
      run(q, all(eq(true, x), eq(x, q))).should == [true]
      run(q, all(eq(x, q), eq(true, x))).should == [true]
    end
  end
end
#
#  def test_any
#    q, x = fresh(2)
#
#    assert_equal(infer(q, eq(x == q, q)), [false])
#
#    assert_equal(infer(q, any(
#                              all(fail, succeed),
#                              all(succeed, fail))),
#                 [])
#    assert_equal(infer(q, any(
#                              all(fail, fail),
#                              all(succeed, succeed))),
#                 ["_.0"])
#    assert_equal(infer(q, any(
#                              all(succeed, succeed),
#                              all(fail, fail))),
#                 ["_.0"])
#    assert_equal(infer(q, any(
#                              all(eq(:olive, q), succeed),
#                              all(eq(:oil, q), succeed))),
#                 [:olive, :oil])
#    assert_equal(infer(1, q, any(
#                                 all(eq(:olive, q), succeed),
#                                 all(eq(:oil, q), succeed))),
#                 [:olive])
#    assert_equal(infer(q, any(
#                              all(eq(:virgin, q), fail),
#                              all(eq(:olive, q), succeed),
#                              all(succeed, succeed),
#                              all(eq(:oil, q), succeed))),
#                 [:olive, "_.0", :oil])
#    assert_equal(infer(q, any(
#                              all(eq(:olive, q), succeed),
#                              all(succeed, succeed),
#                              all(eq(:oil, q), succeed))),
#                 [:olive, "_.0", :oil])
#    assert_equal(infer(2, q, any(
#                              all(eq(:extra, q), succeed),
#                              all(eq(:virgin, q), fail),
#                              all(eq(:olive, q), succeed),
#                              all(eq(:oil, q), succeed))),
#                 [:extra, :olive])
#    x, y = fresh(2)
#    assert_equal(infer(q, all(
#                              eq(:split, x),
#                              eq(:pea, y),
#                              eq([x, y], q))),
#                 [[:split, :pea]])
#    assert_equal(infer(q, all(
#                              any(
#                                all(eq(:split, x), eq(:pea, y)),
#                                all(eq(:navy, x), eq(:bean, y))),
#                              eq([x, y], q))),
#                 [[:split, :pea], [:navy, :bean]])
#    assert_equal(infer(q, all(
#                              any(
#                                all(eq(:split, x), eq(:pea, y)),
#                                all(eq(:navy, x), eq(:bean, y))),
#                              eq([x, y, :soup], q))),
#                 [[:split, :pea, :soup], [:navy, :bean, :soup]])
#
#    def teacupo(x)
#      any(
#        all(eq(:tea, x), succeed),
#        all(eq(:cup, x), succeed))
#    end
#
#    assert_equal(infer(q, teacupo(q)), [:tea, :cup])
#
#    assert_equal(infer(q, all(
#                              any(
#                                all(teacupo(x), eq(true, y), succeed),
#                                all(eq(false, x), eq(true, y))),
#                              eq([x, y], q))),
#                 [[false, true], [:tea, true], [:cup, true]])
#
#    x, y, z = fresh(3)
#    x_ = fresh
#    assert_equal(infer(q, all(
#                              any(
#                                all(eq(y, x), eq(z, x_)),
#                                all(eq(y, x_), eq(z, x))),
#                              eq([y, z], q))),
#                 [["_.0", "_.1"], ["_.0", "_.1"]])
#
#    assert_equal(infer(q, all(
#                              any(
#                                all(eq(y, x), eq(z, x_)),
#                                all(eq(y, x_), eq(z, x))),
#                              eq(false, x),
#                              eq([y, z], q))),
#                 [[false, "_.0"], ["_.0", false]])
#
#    a = eq(true, q)
#    b = eq(false, q)
#    assert_equal(infer(q, b), [false])
#
#    x = fresh
#    b = all(
#          eq(x, q),
#          eq(false, x))
#    assert_equal(infer(q, b), [false])
#
#    x, y = fresh(2)
#    assert_equal(infer(q, eq([x, y], q)), [["_.0", "_.1"]])
#
#    v, w = fresh(2)
#    x, y = v, w
#    assert_equal(infer(q, eq([x, y], q)), [["_.0", "_.1"]])
#  end
#
#  def test_functions
#    q = fresh
#
#    def nullo(l)
#      eq(l, [])
#    end
#
#    def conso(a, d, p)
#      eq([a, d], p)
#    end
#
#    def pairo(p)
#      a, d = fresh(2)
#      conso(a, d, p)
#    end
#
#    def cdro(p, d)
#      a = fresh
#      conso(a, d, p)
#    end
#
#    def caro(p, a)
#      d = fresh
#      conso(a, d, p)
#    end
#
#    assert_equal(infer(q, all(pairo([q, q]), eq(true, q))), [true])
#    assert_equal(infer(q, all(pairo([]), eq(true, q))), [])
#
#    def listo(l)
#      d = fresh
#      any(
#        all(nullo(l), succeed),
#        all(pairo(l), cdro(l, d), defer(method(:listo), d)))
#    end
#
#    assert_equal(infer(q, listo([:a, [:b, [q, [:d, []]]]])), ["_.0"])
#
#    assert_equal(infer(5, q, listo([:a, [:b, [:c, q]]])),
#                 [[],
#                  ["_.0", []],
#                  ["_.0", ["_.1", []]],
#                  ["_.0", ["_.1", ["_.2", []]]],
#                  ["_.0", ["_.1", ["_.2", ["_.3", []]]]]])
#  end
#
#  def test_nesting
#    fresh { |q|
#      assert_equal(infer(q, fresh { |q| eq(q, false) }), ["_.0"])
#    }
#  end
#end

