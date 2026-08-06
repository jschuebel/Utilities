			--new_value = ( (old_value - old_min) / (old_max - old_min) ) * (new_max - new_min) + new_min
			set @Lead1Y = FLOOR(( ( @Lead1Y - 0 ) / (4206.0 - 0) ) * (800.0 - 350.0) + 350.0)
