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
			return perror("'*' symbol found at the start of the $side side of the equation.")
		end
		if (occursin(r"^[\+\-\*]$", val[end]))
			return perror("Mathematical operator found at the end of the $side side of the equation.")
		end
	end
	for (i, tk) in pairs(halfs["left"])
		if (!occursin(r"^(\d|\d?X(\^\d)?|\+|-|\*)$", tk))
			return perror("Malformed input: '$tk'.")
		end

		if (tk == "*" && i > 1 && occursin(r"^(\+|-|\*)$", halfs["left"][i - 1]))
			return perror("Mathematical operator found before '*'.")
		end
	end
end

println("Given input is:")
for arg in ARGS
	println(arg)
	println("\tInitiating tokenization...")
	tokenizeInput(arg)
end
