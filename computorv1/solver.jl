# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    solver.jl                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: senari <ntamayo-@student.42malaga.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/04/20 12:12:39 by senari            #+#    #+#              #
#    Updated: 2024/04/20 12:12:42 by senari           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

function solve(data::Dict{Int64, Float64}, degree::Int64)
    if (degree === 0) # Identities
        if (data[0] == 0) # 0 = 0
            println("The given equation is a polynomial identity. Every real number is a solution.")
        else # N = 0
            println("The resulting expression can't be evaluated. No solutions exist.")
        end
    elseif (degree === 1) # Linear equations aX + N = 0
        println("The solution is: $(-data[0]/data[1])")
    else # Quadratic equations aX² + bX + c = 0
        # Solve it with X = (-b ± √(b²-4ac)) / 2a
        b = haskey(data, 1) ? data[1] : 0
        discriminant = b^2 - 4*data[0]*data[2]
        sqd = discriminant < 0 ? sqrt(Complex(discriminant)) : sqrt(discriminant)
        if (discriminant > 0)
            println("Positive discriminant. The equation has two real solutions:")
            println("X1 = $((-b + sqd) / (2*data[2]))")
            println("X2 = $((-b - sqd) / (2*data[2]))")
        elseif (discriminant == 0)
            println("The discriminant is zero. The equation has a single, repeated, real solution:")
            println("X = $(-b / (2*data[2]))")
        else
            println("Negative discriminant. The equation has two imaginary solutions:")
            println("X1 = $((-b + sqd) / (2*data[2]))")
            println("X2 = $((-b - sqd) / (2*data[2]))")
        end
    end
end
