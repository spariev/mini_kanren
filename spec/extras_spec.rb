require "rspec"
require 'mini_kanren'
require 'mini_kanren/core'
require 'mini_kanren/extras'

module MiniKanren
  class Program
    include MiniKanren::Extras
  end
end

describe "Extras" do
  it "addero" do
    MiniKanren.exec do
      s, b, x, y, r, c, = fresh(8)

      run(s,
          all(full_addero(1, 1, 1, r, c),
              eq([r, c], s))).should == [[1, 1]]

      run(s,
          all(full_addero(b, x, y, r, c),
              eq([b, x, y, r, c], s))).should ==
                 [[0, 0, 0, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 1, 0],
                  [1, 1, 0, 0, 1], [0, 0, 1, 1, 0], [1, 0, 1, 0, 1],
                  [0, 1, 1, 0, 1], [1, 1, 1, 1, 1]]
    end
  end

  it "full_addero" do
    MiniKanren.exec do
      s, b, x, y, r, c, = fresh(8)

      run(s,
          all(full_addero(1, 1, 1, r, c),
              eq([r, c], s))).should == [[1, 1]]

      run(s,
          all(full_addero(b, x, y, r, c),
              eq([b, x, y, r, c], s))).should ==
                 [[0, 0, 0, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 1, 0],
                  [1, 1, 0, 0, 1], [0, 0, 1, 1, 0], [1, 0, 1, 0, 1],
                  [0, 1, 1, 0, 1], [1, 1, 1, 1, 1]]

    end
  end

  it "buld_num" do
    MiniKanren.exec do
      build_num(5).should == [1, [0, [1, []]]]
      build_num(7).should == [1, [1, [1, []]]]
      build_num(9).should == [1, [0, [0, [1, []]]]]
      build_num(17290).should == [0, [1, [0, [1, [0, [0, [0, [1, [1, [1, [0,
                                    [0, [0, [0, [1, []]]]]]]]]]]]]]]]
    end
  end

  it "poso" do
    MiniKanren.exec do
      q, r = fresh(2)

      run(q,
          all(poso([0, [1, [1, []]]]),
              eq(true, q))).should == [true]

      run(q,
          all(poso([1, []]),
              eq(true, q))).should == [true]

      run(q,
          all(poso([]),
              eq(true, q))).should == []

      run(r,
          poso(r)).should == [["_.0", "_.1"]]
    end
  end

  it "gtlo" do
    MiniKanren.exec do
      q = fresh

      run(q,
          all(gt1o([0, [1, []]]),
              eq(true, q))).should == [true]

      run(q,
          all(gt1o([1, []]),
              eq(true, q))).should == []

      run(q,
          all(gt1o([]),
              eq(true, q))).should == []

      run(q,
          gt1o(q)).should == [["_.0", ["_.1", "_.2"]]]
    end
  end

  it "pluso" do
    MiniKanren.exec do
      s, x, y, r, q = fresh(5)

      run(3, s,
          all(addero(0, x, y, r),
              eq([x, y, r], s))).should ==
                 [["_.0", [], "_.0"],
                  [[], ["_.0", "_.1"], ["_.0", "_.1"]],
                  [[1, []], [1, []], [0, [1, []]]]]

      run(s,
          gen_addero(1, [0, [1, [1, []]]], [1, [1, []]], s)).should ==
                 [[0, [1, [0, [1, []]]]]]

      run(s,
          all(pluso(x, y, [1, [0, [1, []]]]),
              eq([x, y], s))).should ==
                 [[[1, [0, [1, []]]], []],
                  [[], [1, [0, [1, []]]]],
                  [[1, []], [0, [0, [1, []]]]],
                  [[0, [0, [1, []]]], [1, []]],
                  [[1, [1, []]], [0, [1, []]]],
                  [[0, [1, []]], [1, [1, []]]]]

      run(q,
          minuso([0, [0, [0, [1, []]]]], [1, [0, [1, []]]], q)).should ==
                 [[1, [1, []]]]

      run(q,
          minuso([0, [1, [1, []]]], [0, [1, [1, []]]], q)).should ==
                 [[]]

      run(q,
          pluso([1, [1, []]], [0, [1, [1, []]]], q)).should ==
                 [[1, [0, [0, [1, []]]]]]
    end
  end

  it "multo" do
    MiniKanren.exec do
      p = fresh

      run(p, multo(build_num(2), build_num(2), p)).should ==
                 [build_num(4)]
      run(p, multo(build_num(4), build_num(4), p)).should ==
                 [build_num(16)]
      run(p, multo(build_num(8), build_num(8), p)).should ==
                 [build_num(64)]
      run(p, multo(build_num(16), build_num(16), p)).should ==
                 [build_num(256)]
      run(p, multo(build_num(32), build_num(32), p)).should ==
                 [build_num(1024)]
      run(p, multo(build_num(1), build_num(32), p)).should ==
                 [build_num(32)]
      run(p, multo(build_num(0), build_num(32), p)).should ==
                 [build_num(0)]
      run(p, multo(build_num(3), build_num(3), p)).should ==
                 [build_num(9)]
      run(p, multo(build_num(3), build_num(5), p)).should ==
                 [build_num(15)]
      run(p, multo(build_num(5), build_num(31), p)).should ==
                 [build_num(155)]
      run(p, multo(build_num(5), build_num(63), p)).should ==
                 [build_num(315)]
      run(p, multo(build_num(7), build_num(31), p)).should ==
                 [build_num(217)]
      run(p, multo(build_num(7), build_num(63), p)).should ==
                 [build_num(441)]
      run(p,
          multo([1, [1, [1, []]]],
                [1, [1, [1, [1, [1, [1, []]]]]]], p)).should ==
          [[1, [0, [0, [1, [1, [1, [0, [1, [1, []]]]]]]]]]]

    end
  end

  it "divo" do
    MiniKanren.exec do
      n, m, q, r, t = fresh(5)

      run(6, t, divo(n, m, q, r), eq([n, m, q, r], t)).should ==
      [[[],
       ["_.0", "_.1"],
       [],
       []],
      [[1, []],
       ["_.0", ["_.1", "_.2"]],
       [],
       [1, []]],
      [["_.0", [1, []]],
       ["_.1", ["_.2", ["_.3", "_.4"]]],
       [],
       ["_.0", [1, []]]],
      [["_.0", ["_.1", [1, []]]],
       ["_.2", ["_.3", ["_.4", ["_.5", "_.6"]]]],
       [],
       ["_.0", ["_.1", [1, []]]]],
      [["_.0", ["_.1", ["_.2", [1, []]]]],
       ["_.3", ["_.4", ["_.5", ["_.6", ["_.7", "_.8"]]]]],
       [],
       ["_.0", ["_.1", ["_.2", [1, []]]]]],
      [["_.0", ["_.1", ["_.2", ["_.3", [1, []]]]]],
       ["_.4", ["_.5", ["_.6", ["_.7", ["_.8", ["_.9", "_.10"]]]]]],
       [],
       ["_.0", ["_.1", ["_.2", ["_.3", [1, []]]]]]]]

      s, q, r = fresh(2)
      run(q, divo(build_num(4), build_num(2), q, build_num(0))).should ==
                 [build_num(2)]
      run(q, divo(build_num(1), build_num(1), q, build_num(0))).should ==
                 [build_num(1)]
      run(q, divo(build_num(8), build_num(4), q, build_num(0))).should ==
                 [build_num(2)]
      run(q, divo(build_num(16), build_num(4), q, build_num(0))).should ==
                 [build_num(4)]
    end
  end
end
