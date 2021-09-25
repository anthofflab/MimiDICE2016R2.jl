using Distributions

# Uncertain parameters defined in "Projections and Uncertainties about Climate
# Change in an Era of Minimal Climate Policies" (Nordhaus, 2018) EViews file
# provided by the AEJ : https://www.aeaweb.org/articles?id=10.1257/pol.20170046

dice_default_mcs = @defsim begin
    t2xco2 = LogNormal(1.106, 0.2646)
	ga0 = Normal(0.076, 0.056)
	gsigma1 = Normal(-0.0152, 0.0032)
	mueq = LogNormal(5.851, 0.2649)
	a2 = Normal(0.00227, 0.001135)

    # save(damages.DAMAGES)
	# save(grosseconomy.YGROSS)
	# save(emissions.E)
	# save(co2cycle.MU)
	# save(damages.DAMFRAC)
end

function getmcs()
    return deepcopy(dice_default_mcs)
end
