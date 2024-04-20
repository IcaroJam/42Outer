# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    parser.jl                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: senari <ntamayo-@student.42malaga.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/04/15 08:29:34 by senari            #+#    #+#              #
#    Updated: 2024/04/20 12:12:19 by senari           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

include("perror.jl")

function  getUnicodeSuperscript(num::Number)
	ret = num === 0 ? "" : "X"
	if (num < 2)
		return ret
	end
	for i in num
		if (i === 1)
			ret *= '\u00b9'
		elseif (1 < i < 4)
			ret *= Char(0x00b0 + i)
		else
			ret *= Char(0x2070 + i)
		end
	end
	ret
end

function tokenizeInput(inp::String)
	println("\n\tInitiating tokenization...")

	# Divide the equation into it's left and righthandside:
	halfs = split(inp, '=')
	if (length(halfs) !== 2)
		perror("The provided input must have one and only one '='.")
	end

	# Cleanup of duped operators and token validation:
	spaceOutOps = (str) -> split(replace(str, r"(\+|-|\*)" => s" \1 "))
	halfs = Dict("left" => spaceOutOps(halfs[1]), "right" => spaceOutOps(halfs[2]))
	if (isempty(halfs["left"]) || isempty(halfs["right"]))
		perror("The provided input must have both left and right sides in the equation.")
	end
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
	println("\tTokenization completed!\n")
	dedupedtkns
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
	sortedPol = sort(collect(pol), by = x -> x[1])
	degree = 0
	firstPrintFlag = false
	print("Reduced form:")
	for (ord, num) in sortedPol
		if (num != 0)
			if (ord > degree)
				degree = ord
			end
			print(" $(num < 0 ? "- " : firstPrintFlag ? "+ " : "")$(isinteger(num) ? round(Int, abs(num)) : round(abs(num), digits=4))$(getUnicodeSuperscript(ord))")
			firstPrintFlag = true
		end
	end
	println(" = 0")
	if (degree > 2)
		perror("Polynomial degree: $degree. Computorv can't solve polinomials of order greater than 2.")
	else
		println("Polynomial degree: $degree")
	end
	Dict("degree" => degree, "data" => pol)
end

function parseInput(inp::AbstractString)
    lexer(tokenizeInput(uppercase(inp)))
end
