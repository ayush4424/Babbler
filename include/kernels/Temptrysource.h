#pragma once

// Including the "ADKernel" base class here so we can extend it
#include "ADKernel.h"

/**
 * Computes the residual contribution: K * grad_test * grad_u.
 */
class Temptrysource : public ADKernel
{
public:
	static InputParameters validParams();
	Temptrysource(const InputParameters& parameters);

protected:
	/// ADKernel objects must override precomputeQpResidual
	virtual ADReal computeQpResidual() override;

	/// The variables which hold the value for q
	const Real& _volumetric_heat;
};