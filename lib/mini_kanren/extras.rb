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

require 'mini_kanren/core'

module MiniKanren
  module Extras
    def anyo(g)
      conde(
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
      conde(
        all(nullo(l), succeed),
        all(pairo(l), cdro(l, d), defer(method(:listo), d)))
    end

    def membero(x, l)
      a, d = fresh(2)
      conde(
        all(caro(l, a),
            eq(a, x)),
        all(cdro(l, d),
            defer(method(:membero), x, d)))
    end

    def full_addero(b, x, y, r, c)
      conde(
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
      conde(
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
      conde(
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
      conde(
        all(nullo(q), pairo(p)),
        fresh { |x, y, z| all(
          cdro(q, x),
          cdro(p, y),
          conde(
            all(nullo(n),
                cdro(m, z),
                defer(method(:bound_multo), x, y, z, [])),
            all(cdro(n, z),
                defer(method(:bound_multo), x, y, z, m)))) })
    end

    def eqlo(n, m)
      a, x, b, y = fresh(4)
      conde(
        all(eq([], n), eq([], m)),
        all(eq([1, []], n), eq([1, []], m)),
        all(eq([a, x], n), poso(x),
            eq([b, y], m), poso(y),
            defer(method(:eqlo), x, y)))
    end

    def ltlo(n, m)
      a, x, b, y = fresh(4)
      conde(
        all(eq([], n), poso(m)),
        all(eq([1, []], n), gt1o(m)),
        all(eq([a, x], n), poso(x),
            eq([b, y], m), poso(y),
            defer(method(:ltlo), x, y)))
    end

    def lto(n, m)
      x = fresh
      conde(
        ltlo(n, m),
        all(eqlo(n, m),
            poso(x),
            pluso(n, x, m)))
    end

    def divo(n, m, q, r)
      nh, nl, qh, ql, qlm, qlmr, rr, rh = fresh(8)
      conde(
        all(eq(r, n), eq([], q), ltlo(n, m)),
        all(eq([1, []], q), eqlo(n, m), pluso(r, m, n),
            lto(r, m)),
        all(ltlo(m, n),
            lto(r, m),
            poso(q),
            splito(n, r, nl, nh),
            splito(q, r, ql, qh),
            conde(
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
      conde(
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
  end
end
