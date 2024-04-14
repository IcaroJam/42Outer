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
	# println(halfs)
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
	# println(dedupedtkns)
	return dedupedtkns
end

function lexer(tkns::Dict{String, Vector{String}})
	pol = Dict{Int64, Float64}()
	updatePol = function(num, ord, side)
		sign = side == "left" ? 1 : -1

		if (haskey(pol, ord))
			pol[ord] += sign * num
		else
			pol[ord] = sign * num
		end
	end

	for (side, hlf) in tkns
		num = 0
		ord = 0
		i = 1
		while i <= length(hlf)
			if (hlf[i] == "-" || hlf[i] == "+")
				updatePol(num, ord, side)
				num = hlf[i] == "-" ? -1 : 1
				ord = 0
			elseif (hlf[i] == "*")
				if (hlf[i + 1] == "-")
					num *= -1
					i += 1 # Skip straight to the next number or X
				end
			else # If it isn't an operator it has to be a number or X
				sub = match(r"(\d+\.?\d*)?(?:(X)\^?(\d+)?)?", hlf[i]).captures
				if (!isnothing(sub[1]))
					num *= parse(Float64, sub[1])
				end
				# If there's no numeric order but there's an X (e.g.: 5X), the order is 1
				if (!isnothing(sub[3]))
					ord += parse(Int64, sub[3])
				elseif(!isnothing(sub[2]))
					ord += 1
				end
			end
			i += 1
		end
		updatePol(num, ord, side)
	end
	retPol = sort(collect(pol), by = x -> x[1])
	print("Reduced form:")
	for (ord, num) in retPol
		if (num != 0)
			print(" $(num < 0 ? '-' : '+') $(isinteger(num) ? round(Int, abs(num)) : round(abs(num), digits=4)) * X^$ord")
		end
	end
end

println("Given input is:")
for arg in ARGS
	println(arg)
	println("\tInitiating tokenization...")
	lexer(tokenizeInput(uppercase(arg)))
end
