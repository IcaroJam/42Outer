# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    computorv1.jl                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ntamayo- <ntamayo-@student.42malaga.com>   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/04/12 13:20:46 by ntamayo-          #+#    #+#              #
#    Updated: 2024/04/20 12:12:09 by senari           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

include("parser.jl")
include("solver.jl")

nArgs = length(ARGS)
if (nArgs === 0)
	printstyled(stdout, "No arguments were given. Computorvn't :(\n", color=:light_yellow)
	exit(0)
elseif(nArgs > 1)
	printstyled(stdout, "More than a one argument was given. The first one will be taken as a polynomial equation, the rest will be ignored.\n", color=:light_yellow)
end

println("Given input is:")
arg = ARGS[1]
println(arg)
parsedData = parseInput(arg)

# Solver aquí: En función del grado hace una cosa u otra. Para grado dos vale con aplicar
# la fórmula, calculando las distintas partes individualmente para ver si la solución es real
# (interior de la raíz +) o no, etc...
# Manejar identidades, orden 1, orden 2 con alguna o ninguna solución compleja...
solve(parsedData["data"], parsedData["degree"])