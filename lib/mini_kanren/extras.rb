=begin
MiniKanren Extras Copyright (C) 2006 Scott Dial

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc.,
59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
=end

require 'core'

def anyo(g)
  any(
    g,
    defer(method(:anyo), g))
end

def nevero
  anyo(eq(true, false))
end

def alwayso
  anyo(eq(true, true))
end

def nullo(l)
  eq(l, [])
end

def conso(a, d, p)
  eq([a, d], p)
end

def pairo(p)
  a, d = fresh(2)
  eq([a, d], p)
end

def cdro(p, d)
  a = fresh
  eq([a, d], p)
end

def caro(p, a)
  d = fresh
  eq([a, d], p)
end

def listo(l)
  d = fresh
  any(
    all(nullo(l), succeed),
    all(pairo(l), cdro(l, d), defer(method(:listo), d)))
end

def membero(x, l)
  a, d = fresh(2)
  any(
    all(caro(l, a),
        eq(a, x)),
    all(cdro(l, d),
        defer(method(:membero), x, d)))
end

def full_addero(b, x, y, r, c)
  any(
    all(eq(0, b), eq(0, x), eq(0, y), eq(0, r), eq(0, c)),
    all(eq(1, b), eq(0, x), eq(0, y), eq(1, r), eq(0, c)),
    all(eq(0, b), eq(1, x), eq(0, y), eq(1, r), eq(0, c)),
    all(eq(1, b), eq(1, x), eq(0, y), eq(0, r), eq(1, c)),
    all(eq(0, b), eq(0, x), eq(1, y), eq(1, r), eq(0, c)),
    all(eq(1, b), eq(0, x), eq(1, y), eq(0, r), eq(1, c)),
    all(eq(0, b), eq(1, x), eq(1, y), eq(0, r), eq(1, c)),
    all(eq(1, b), eq(1, x), eq(1, y), eq(1, r), eq(1, c)))
end

def build_num(n)
  if n == 0
    []
  elsif n % 2 == 0
    [0, build_num(n / 2)]
  else
    [1, build_num(n / 2)]
  end
end

def poso(n)
  a, d = fresh(2)
  eq([a, d], n)
end

def gt1o(n)
  a, ad, dd = fresh(3)
  eq([a, [ad, dd]], n)
end

def addero(d, n, m, r)
  a, c = fresh(2)
  any(
    all(eq(0, d), eq([], m), eq(n, r)),
    all(eq(0, d), eq([], n), eq(m, r),
        poso(m)),
    all(eq(1, d), eq([], m),
        defer(method(:addero), 0, n, [1, []], r)),
    all(eq(1, d), eq([], n), poso(m),
        defer(method(:addero), 0, [1, []], m, r)),
    all(eq([1, []], n), eq([1, []], m),
        eq([a, [c, []]], r),
        full_addero(d, 1, 1, a, c)),
    all(eq([1, []], n), gen_addero(d, n, m, r)),
    all(eq([1, []], m), gt1o(n), gt1o(r),
        defer(method(:addero), d, [1, []], n, r)),
    all(gt1o(n), gen_addero(d, n, m, r)))
end

def gen_addero(d, n, m, r)
  a, b, c, e, x, y, z = fresh(7)
  all(eq([a, x], n),
      eq([b, y], m), poso(y),
      eq([c, z], r), poso(z),
      full_addero(d, a, b, c, e),
      defer(method(:addero), e, x, y, z))
end

def pluso(n, m, k)
  addero(0, n, m, k)
end

def minuso(n, m, k)
  pluso(m, k, n)
end

def multo(n, m, p)
  x, y, z = fresh(3)
  any(
    all(eq([], n), eq([], p)),
    all(poso(n), eq([], m), eq([], p)),
    all(eq([1, []], n), poso(m), eq(m, p)),
    all(gt1o(n), eq([1, []], m), eq(n, p)),
    all(
      eq([0, x], n), poso(x),
      eq([0, z], p), poso(z),
      gt1o(m),
      defer(method(:multo), x, m, z)),
    all(
      eq([1, x], n), poso(x),
      eq([0, y], m), poso(y),
      defer(method(:multo), m, n, p)),
    all(
      eq([1, x], n), poso(x),
      eq([1, y], m), poso(y),
      defer(method(:odd_multo), x, n, m, p)))
end

def odd_multo(x, n, m, p)
  fresh { |q| all(
    bound_multo(q, p, n, m),
    multo(x, m, q),
    pluso([0, q], m, p)) }
end

def bound_multo(q, p, n, m)
  any(
    all(nullo(q), pairo(p)),
    fresh { |x, y, z| all(
      cdro(q, x),
      cdro(p, y),
      any(
        all(nullo(n),
            cdro(m, z),
            defer(method(:bound_multo), x, y, z, [])),
        all(cdro(n, z),
            defer(method(:bound_multo), x, y, z, m)))) })
end

def eqlo(n, m)
  a, x, b, y = fresh(4)
  any(
    all(eq([], n), eq([], m)),
    all(eq([1, []], n), eq([1, []], m)),
    all(eq([a, x], n), poso(x),
        eq([b, y], m), poso(y),
        defer(method(:eqlo), x, y)))
end

def ltlo(n, m)
  a, x, b, y = fresh(4)
  any(
    all(eq([], n), poso(m)),
    all(eq([1, []], n), gt1o(m)),
    all(eq([a, x], n), poso(x),
        eq([b, y], m), poso(y),
        defer(method(:ltlo), x, y)))
end

def lto(n, m)
  x = fresh
  any(
    ltlo(n, m),
    all(eqlo(n, m),
        poso(x),
        pluso(n, x, m)))
end

def divo(n, m, q, r)
  nh, nl, qh, ql, qlm, qlmr, rr, rh = fresh(8)
  any(
    all(eq(r, n), eq([], q), ltlo(n, m)),
    all(eq([1, []], q), eqlo(n, m), pluso(r, m, n),
        lto(r, m)),
    all(ltlo(m, n),
        lto(r, m),
        poso(q),
        splito(n, r, nl, nh),
        splito(q, r, ql, qh),
        any(
          all(eq([], nh),
              eq([], qh),
              minuso(nl, r, qlm),
              multo(ql, m, qlm)),
          all(poso(nh),
              multo(ql, m, qlm),
              pluso(qlm, r, qlmr),
              minuso(qlmr, nl, rr),
              splito(rr, r, [], rh),
              defer(method(:divo), nh, m, qh, rh)))))
end

def splito(n, r, l, h)
  b, n_, a, r_, l_ = fresh(5)
  any(
    all(eq([], n), eq([], h), eq([], l)),
    all(eq([0, [b, n_]], n),
        eq([], r),
        eq([b, n_], h),
        eq([], l)),
    all(eq([1, n_], n),
        eq([], r),
        eq(n_, h),
        eq([1, []], l)),
    all(eq([0, [b, n_]], n),
        eq([a, r_], r),
        eq([], l),
        defer(method(:splito), [b, n_], r_, [], h)),
    all(eq([1, n_], n),
        eq([a, r_], r),
        eq([1, []], l),
        defer(method(:splito), n_, r_, [], h)),
    all(eq([b, n_], n),
        eq([a, r_], r),
        eq([b, l_], l),
        poso(l_),
        defer(method(:splito), n_, r_, l_, h)))
end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

class TC_MiniKanren_Extras < Test::Unit::TestCase
  include MiniKanren

  def test_full_addero
    s, b, x, y, r, c, = fresh(8)

    assert_equal(infer(s, all(full_addero(1, 1, 1, r, c), eq([r, c], s))),
                 [[1, 1]])
    assert_equal(infer(s, all(full_addero(b, x, y, r, c),
                              eq([b, x, y, r, c], s))),
                 [[0, 0, 0, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 1, 0],
                  [1, 1, 0, 0, 1], [0, 0, 1, 1, 0], [1, 0, 1, 0, 1],
                  [0, 1, 1, 0, 1], [1, 1, 1, 1, 1]])
  end

  def test_build_num
    assert_equal(build_num(5), [1, [0, [1, []]]])
    assert_equal(build_num(7), [1, [1, [1, []]]])
    assert_equal(build_num(9), [1, [0, [0, [1, []]]]])
    assert_equal(build_num(17290), [0, [1, [0, [1, [0, [0, [0, [1, [1, [1, [0,
                                    [0, [0, [0, [1, []]]]]]]]]]]]]]]])
  end

  def test_poso
    q, r = fresh(2)

    assert_equal(infer(q, all(poso([0, [1, [1, []]]]), eq(true, q))), [true])
    assert_equal(infer(q, all(poso([1, []]), eq(true, q))), [true])
    assert_equal(infer(q, all(poso([]), eq(true, q))), [])
    assert_equal(infer(r, poso(r)), [["_.0", "_.1"]])
  end

  def test_gt1o
    q = fresh

    assert_equal(infer(q, all(gt1o([0, [1, []]]), eq(true, q))), [true])
    assert_equal(infer(q, all(gt1o([1, []]), eq(true, q))), [])
    assert_equal(infer(q, all(gt1o([]), eq(true, q))), [])
    assert_equal(infer(q, gt1o(q)), [["_.0", ["_.1", "_.2"]]])
  end

  def test_pluso
    s, x, y, r, q = fresh(5)

    assert_equal(infer(3, s, all(addero(0, x, y, r), eq([x, y, r], s))),
                 [["_.0", [], "_.0"],
                  [[], ["_.0", "_.1"], ["_.0", "_.1"]],
                  [[1, []], [1, []], [0, [1, []]]]])
    assert_equal(infer(s, gen_addero(1, [0, [1, [1, []]]], [1, [1, []]], s)),
                 [[0, [1, [0, [1, []]]]]])
    assert_equal(infer(s, all(pluso(x, y, [1, [0, [1, []]]]), eq([x, y], s))),
                 [[[1, [0, [1, []]]], []],
                  [[], [1, [0, [1, []]]]],
                  [[1, []], [0, [0, [1, []]]]],
                  [[0, [0, [1, []]]], [1, []]],
                  [[1, [1, []]], [0, [1, []]]],
                  [[0, [1, []]], [1, [1, []]]]])
    assert_equal(infer(q, minuso([0, [0, [0, [1, []]]]], [1, [0, [1, []]]], q)),
                 [[1, [1, []]]])
    assert_equal(infer(q, minuso([0, [1, [1, []]]], [0, [1, [1, []]]], q)),
                 [[]])
    assert_equal(infer(q, pluso([1, [1, []]], [0, [1, [1, []]]], q)),
                 [[1, [0, [0, [1, []]]]]])
  end

  def test_multo
    p = fresh

    assert_equal(infer(p, multo(build_num(2), build_num(2), p)),
                 [build_num(4)])
    assert_equal(infer(p, multo(build_num(4), build_num(4), p)),
                 [build_num(16)])
    assert_equal(infer(p, multo(build_num(8), build_num(8), p)),
                 [build_num(64)])
    assert_equal(infer(p, multo(build_num(16), build_num(16), p)),
                 [build_num(256)])
    assert_equal(infer(p, multo(build_num(32), build_num(32), p)),
                 [build_num(1024)])
    assert_equal(infer(p, multo(build_num(1), build_num(32), p)),
                 [build_num(32)])
    assert_equal(infer(p, multo(build_num(0), build_num(32), p)),
                 [build_num(0)])

    assert_equal(infer(p, multo(build_num(3), build_num(3), p)),
                 [build_num(9)])

    assert_equal(infer(p, multo(build_num(3), build_num(5), p)),
                 [build_num(15)])
    assert_equal(infer(p, multo(build_num(5), build_num(31), p)),
                 [build_num(155)])
    assert_equal(infer(p, multo(build_num(5), build_num(63), p)),
                 [build_num(315)])
    assert_equal(infer(p, multo(build_num(7), build_num(31), p)),
                 [build_num(217)])
    assert_equal(infer(p, multo(build_num(7), build_num(63), p)),
                 [build_num(441)])
    assert_equal(infer(p, multo([1, [1, [1, []]]],
                                [1, [1, [1, [1, [1, [1, []]]]]]], p)),
                 [[1, [0, [0, [1, [1, [1, [0, [1, [1, []]]]]]]]]]])
  end

  def test_divo
    n, m, q, r, t = fresh(5)
    assert_equal(infer(6, t, divo(n, m, q, r), eq([n, m, q, r], t)),
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
       ["_.0", ["_.1", ["_.2", ["_.3", [1, []]]]]]]])

    s, q, r = fresh(2)
    assert_equal(infer(q, divo(build_num(4), build_num(2), q, build_num(0))),
                 [build_num(2)])
    assert_equal(infer(q, divo(build_num(1), build_num(1), q, build_num(0))),
                 [build_num(1)])
    assert_equal(infer(q, divo(build_num(8), build_num(4), q, build_num(0))),
                 [build_num(2)])
    assert_equal(infer(q, divo(build_num(16), build_num(4), q, build_num(0))),
                 [build_num(4)])
  end
end
