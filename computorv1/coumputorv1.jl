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

function perror(str::AbstractString)
	printstyled(stderr, "$str\n", color=:red)
end

function tokenizeInput(inp::String)
	# Divide the equation into it's left and righthandside:
	halfs = split(inp, '=')
	if (length(halfs) !== 2)
		return perror("The provided input must have one and only one '='.")
	elseif (isempty(halfs[1]) || isempty(halfs[2]))
		return perror("The provided input must have both left and right sides in the equation.")
	end

	# Cleanup of duped operators and token validation:
	spaceOutOps = (str) -> split(replace(str, r"(\+|-|\*)" => s" \1 "))
	halfs = Dict("left" => spaceOutOps(halfs[1]), "right" => spaceOutOps(halfs[2]))
	println(halfs)
	for (side, val) in halfs
		if (val[1] == "*")
			return perror("'*' operator found at the start of the $side side of the equation.")
		end
		if (occursin(r"^[\+\-\*]$", val[end]))
			return perror("Mathematical operator found at the end of the $side side of the equation.")
		end
	end
	dedupedtkns = Dict("left" => String[], "right" => String[])
	for (side, half) in halfs
		for tk in half
			if (!occursin(r"^(\d|\d?X(\^\d)?|\+|-|\*)$", tk))
				return perror("Malformed input: '$tk'.")
			end

			if (tk == "*" && occursin(r"^(\+|-|\*)$", dedupedtkns[side][end]))
				return perror("Mathematical operator found before '*'.")
			elseif (tk == "+" && !isempty(dedupedtkns[side]) && (dedupedtkns[side][end] == "-" || dedupedtkns[side][end] == "+"))
				continue
			elseif(tk == "-" && !isempty(dedupedtkns[side]))
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
end

println("Given input is:")
for arg in ARGS
	println(arg)
	println("\tInitiating tokenization...")
	tokenizeInput(arg)
end
