# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    perror.jl                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: senari <ntamayo-@student.42malaga.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/04/15 08:31:39 by senari            #+#    #+#              #
#    Updated: 2024/04/15 08:31:42 by senari           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

function perror(str::AbstractString, excode = -1)
	printstyled(stderr, "$str\n", color=:red)
	exit(excode)
end
