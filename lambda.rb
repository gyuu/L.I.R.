# 数字
ZERO = -> f { -> x { x }}
ONE = -> f { -> x { f[x] }}
FIVE = -> f { -> x { f[f[f[f[f[x]]]]] }}


# 布尔值
TRUE = -> x { -> y { x }}
FALSE = -> x { -> y { y }}


# PAIR 为二元组，可以保存两个元素。
PAIR = -> x { -> y { -> f { f[x][y] }}}
LEFT = -> x { -> y { x }}
RIGHT = -> x { -> y { y }}

# 接受一个 PAIR p, 返回一个新 PAIR, 含有的值是 [p[RIGHT], p[RIGHT]+1]。
# 如果以 [x, 0] 为初始值，调用 n 次之后返回的值是 [n-1, n]。
# 如果取左边的值，可以用来做递减操作。
SLIDE = -> p { 
	PAIR[p[RIGHT]][INCR[p[RIGHT]]] 
}


# 算术操作...
INCR = -> n { -> f { -> x { f[n[f][x]] }}}

DECR = -> n { 
	n[SLIDE][PAIR[ZERO][ZERO]][LEFT]
}

ADD = -> x { -> y { x[INCR][y] }}

# SUB[x][y] 表示 x-y, 所以是对 x 做 y 次递减。
SUB = -> x { -> y { y[DECR][x] }}

MULTI = -> x { -> y { x[ADD[y]][ZERO] }}


# 条件操作...
IF = -> c { c }

IS_ZERO = -> n { 
	n[-> x { FALSE }][TRUE] 
}

IS_NONZERO = -> n {
	n[-> x { TRUE }][FALSE]
}

# 由于使用对某函数的调用次数来表示数字，因此数字系统只能表示非负数。
# 所以 a - b 最小只能为 0，判断 <= 只要判断减法结果是否为 0.
LESS_EQUAL = -> x { -> y { IS_ZERO[SUB[x][y]] }}
# 减法不为 0 就是大于 0 了。
BIGGER_THAN = -> x { -> y { IS_NONZERO[SUB[x][y]] }}


# Y 组合子。
Y = -> f { -> h { -> x { f[h[h]][x] }}[-> h { -> x { f[h[h]][x] }}] }
# 这个 Y 组合子对于正常的 Ruby 函数是正确的。
# 但是对于我们的 lambda 演算系统，没有实现延迟求值，会造成无限循环。

# 适用于我们构建的 lambda 演算的 Z 组合子，实现了延迟求值。
Z = -> f { 
	-> h { -> x { -> y { f[h[h]][x][y] } }}[
		-> h { -> x { -> y { f[h[h]][x][y] } }}
	]
}

# 实际上上面的 Y 组合子没有错误，只不过在使用 Y 时，我们需要在写递归函数中时，
# 手动进行延迟求值，而在 Z 中我们已经添加了延迟求值，在写递归函数时就不用了。


# 辅助函数，用来在 irb 显示计算结果。
def to_integer(num)
	num[-> n { n+1 }][0]
end

def to_bool(b)
	b[true][false]
end


# 应用：

# 使用递归实现的阶乘函数。
fact_worker = -> f {
	-> n {
		IF[IS_ZERO[n]][ONE][MULTI[n][f[SUB[n][ONE]]]]
	}
}
FACT = Z[fact_worker]