# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    coumputorv1.jl                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ntamayo- <ntamayo-@student.42malaga.com>   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/04/12 13:20:46 by ntamayo-          #+#    #+#              #
#    Updated: 2024/04/12 13:29:18 by ntamayo-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

function perror(str::AbstractString, excode = -1)
	printstyled(stderr, "$str\n", color=:red)
	exit(excode)
end

function tokenizeInput(inp::String)
	# Divide the equation into it's left and righthandside:
	halfs = split(inp, '=')
	if (length(halfs) !== 2)
		perror("The provided input must have one and only one '='.")
	elseif (isempty(halfs[1]) || isempty(halfs[2]))
		perror("The provided input must have both left and right sides in the equation.")
	end

	# Cleanup of duped operators and token validation:
	spaceOutOps = (str) -> split(replace(str, r"(\+|-|\*)" => s" \1 "))
	halfs = Dict("left" => spaceOutOps(halfs[1]), "right" => spaceOutOps(halfs[2]))
	println(halfs)
	for (side, val) in halfs
		if (val[1] == "*")
			perror("'*' operator found at the start of the $side side of the equation.")
		end
		if (occursin(r"^[\+\-\*]$", val[end]))
			perror("Mathematical operator found at the end of the $side side of the equation.")
		end
	end
	dedupedtkns = Dict("left" => ["+"], "right" => ["+"])
	for (side, half) in halfs
		for tk in half
			if (!occursin(r"^(\d+\.?\d*|(\d+\.?\d*)?X(\^\d+)?|\+|-|\*)$", tk))
				perror("Malformed input: '$tk'.")
			end

			if (tk == "*" && occursin(r"^(\+|-|\*)$", dedupedtkns[side][end]))
				perror("Mathematical operator found before '*'.")
			elseif (tk == "+" && (dedupedtkns[side][end] == "-" || dedupedtkns[side][end] == "+"))
				continue
			elseif(tk == "-")
				if (dedupedtkns[side][end] == "-")
					dedupedtkns[side][end] = "+"
				elseif (dedupedtkns[side][end] == "+")
					dedupedtkns[side][end] = "-"
				else
					push!(dedupedtkns[side], tk)
				end
			else
				push!(dedupedtkns[side], tk)
			end
		end
	end
	println(dedupedtkns)
	return dedupedtkns
end

function lexer(tkns::Dict{String, Vector{String}})
	retPol = [0., 0., 0.] # Organized as [Order0, Order1, Order2]
	updatePol = function(num, ord, side)
		sign = side == "left" ? 1 : -1

		retPol[ord + 1] += sign * num
	end

	for (side, hlf) in tkns
		num = 0
		ord = 0
		i = 1
		while i <= length(hlf)
			if (hlf[i] == "-")
				println("PREADD: $num, $ord")
				updatePol(num, ord, side)
				num = -1
				ord = 0
			elseif (hlf[i] == "+")
				println("PREADD: $num, $ord")
				updatePol(num, ord, side)
				num = 1
				ord = 0
			elseif (hlf[i] == "*")
				if (hlf[i + 1] == "-")
					num *= -1
					i += 1 # Skip straight to the next number or X
				end
			else # If it isn't an operator it has to be a number or X
				sub = match(r"(\d+\.?\d*)?(?:(X)\^?(\d+)?)?", hlf[i]).captures
				println("CAPTURAS: $sub")
				if (!isnothing(sub[1]))
					num *= parse(Float64, sub[1])
				end
				if (!isnothing(sub[3]))
					ord += parse(Int64, sub[3])
				elseif(!isnothing(sub[2]))
					ord += 1
				end
			end
			i += 1
		end
		println("PREADD: $num, $ord")
		updatePol(num, ord, side)
	end
	println(retPol)
end

println("Given input is:")
for arg in ARGS
	println(arg)
	println("\tInitiating tokenization...")
	lexer(tokenizeInput(arg))
end
