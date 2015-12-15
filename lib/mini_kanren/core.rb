=begin
MiniKanren Copyright (C) 2006 Scott Dial

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

module MiniKanren
  module Core
    class Var; end
    class Subst < Hash; end

    def unify(u, v, s)
      u = walk(u, s)
      v = walk(v, s)

      if u.equal?(v)
        s
      elsif u.instance_of?(Var)
        if v.instance_of?(Var)
          return ext_s(u, v, s)
        else
          return ext_s_check(u, v, s)
        end
      elsif v.instance_of?(Var)
        return ext_s_check(v, u, s)
      elsif u.instance_of?(Array) && v.instance_of?(Array)
        if u.length != v.length
          return nil
        elsif u.empty? && v.empty?
          return s
        else
          u.zip(v).each { |u, v|
            s = unify(u, v, s)
            break if s.nil? }
          return s
        end
      elsif u == v
        s
      else
        nil
      end
    end

    def walk(v, s)
      if v.instance_of?(Var) && s.has_key?(v)
        walk(s[v], s)
      else
        v
      end
    end

    def ext_s_check(x, v, s)
      occurs_check(x, v, s) ? nil : ext_s(x, v, s)
    end

    def occurs_check(x, v, s)
      v = walk(v, s)

      if v.instance_of?(Var)
        x.equal?(v)
      elsif v.instance_of?(Array)
        r = v.find { |vv| occurs_check(x, vv, s) == true }
        !r.nil?
      else
        false
      end
    end

    def ext_s(x, v, s)
      s[x] = v
      s
    end

    def reify_s(v, s)
      v = walk(v, s)

      if v.instance_of?(Var)
        ext_s(v, reify_name(s.length), s)
      elsif v.instance_of?(Array) && v.length
        v.each { |v| s = reify_s(v, s) }
        s
      else
        s
      end
    end

    def reify(v, s)
      v = walk_all(v, s)
      walk_all(v, reify_s(v, Subst.new))
    end

    def walk_all(w, s)
      v = walk(w, s)

      if v.instance_of?(Array)
        v.map { |v| walk_all(v, s) }
      else
        v
      end
    end

    def reify_name(n)
      "_." + n.to_s
    end

    def mplus(ss, f)
      if ss.nil?
        f.call
      elsif ss.instance_of?(Proc)
        lambda { mplus(f.call, ss) }
      elsif ss.instance_of?(Array)
        [ss[0], lambda { mplus(ss[1].call, f) }]
      else
        [ss, f]
      end
    end

    def take(n, f)
      res = []
      while !n || n > 0
        ss = f.call
        if ss.nil?
          return res
        elsif ss.instance_of?(Proc)
          f = ss
        elsif ss.instance_of?(Array)
          n -= 1 if n
          res << ss[0]
          f = ss[1]
        else
          res << ss
          return res
        end
      end
      res
    end

    def bind(ss, goal)
      if ss.nil?
        nil
      elsif ss.instance_of?(Proc)
        lambda { bind(ss.call, goal) }
      elsif ss.instance_of?(Array)
        mplus(goal.call(ss[0]), lambda { bind(ss[1].call, goal) })
      else
        goal.call(ss)
      end
    end

    def mplus_all(goals, s)
      if goals.length == 1
        goals[0].call(s)
      else
        mplus(goals[0].call(s.clone), lambda { mplus_all(goals[1..-1], s) })
      end
    end

    def eq(u, v)
      lambda { |s|
        s = unify(u, v, s)
        s.nil? ? nil : s }
    end

    def all(*goals)
      return succeed if goals.length == 0
      lambda { |s|
        goals.each { |goal| s = bind(s, goal) }
        s }
    end

    def conde(*goals)
      return succeed if goals.length == 0
      lambda { |s| lambda { mplus_all(goals, s) } }
    end

    # project(x, lambda { |x| eq(q, x + x) })
    def project(u, block)
      lambda do |s|
        walked_u = walk_all(u, s)
        g = block.call(walked_u)
        g.call(s)
      end
    end

    def defer(func, *args)
      if func.arity >= 0
        fixed_arity = func.arity
        variadic = false
      else
        fixed_arity = func.arity.abs - 1
        variadic = true
      end
      if fixed_arity > args.length || (!variadic && fixed_arity > args.length)
        raise ArgumentError, "(#{func}) wrong number of arguments " +
            "(#{args.length} for #{fixed_arity})"
      end
      lambda { |s| func.call(*args).call(s) }
    end

    def succeed
      lambda { |s| s }
    end

    def fail
      lambda { |s| nil }
    end

    # fresh { |q| all(
    #   eq(q, true),
    #   fresh { |q|
    #     eq(q, false) } ) }
    #
    # x = fresh
    # x, y = fresh(2)
    def fresh(n = -1, &block)
      if block.nil?
        if n == -1
          Var.new
        else
          vars = []
          for i in 1..n
            vars << Var.new
          end
          vars
        end
      else
        vars = []
        for i in 1..block.arity
          vars << Var.new
        end
        block.call(*vars)
      end
    end

    # run(var, goal0, goal*, ...)
    # run(n, var, goal0, goal*, ...)
    def run(*args)
      if args[1].instance_of?(Proc)
        n, v, *goals = false, *args
      else
        n, v, *goals = args
      end

      if goals.length == 1
        goal = goals[0]
      else
        goal = all(*goals)
      end

      ss = take(n, lambda { goal.call(Subst.new) })
      ss.map! { |s| reify(v, s) }
    end
  end
end
extend MiniKanren::Core
Kernel.send(:include, MiniKanren::Core)
