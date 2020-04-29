fn (mut g Gen) free_scope_vars(pos int) {
	scope := g.file.scope.innermost(pos)
	for _, obj in scope.objects {
		match obj {
			ast.Var {
				// println('//////')
				// println(var.name)
				// println(var.typ)
				// if var.typ == 0 {
				// // TODO why 0?
				// continue
				// }
				v := *it //为什么要有*
				sym := g.table.get_type_symbol(v.typ)
				is_optional := v.typ.flag_is(.optional)
				if sym.kind == .array && !is_optional {
					g.writeln('array_free($v.name); // autofreed')
				}
				if sym.kind == .string && !is_optional {
					// Don't free simple string literals.
					t := typeof(v.expr)
					match v.expr {
						ast.StringLiteral {
							g.writeln('// str literal')
							continue
						}
						else {
							// NOTE/TODO: assign_stmt multi returns variables have no expr
							// since the type comes from the called fns return type
							g.writeln('// other ' + t)
							continue
						}
					}
					g.writeln('string_free($v.name); // autofreed')
				}
			}
			else {}
		}
	}
}
