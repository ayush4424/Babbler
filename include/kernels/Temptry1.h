#pragma once

// Including the "ADKernel" base class here so we can extend it
#include "ADKernelGrad.h"

/**
 * Computes the residual contribution: K * grad_test * grad_u.
 */
class Temptry1 : public ADKernelGrad
{
public:
	static InputParameters validParams();

	Temptry1(const InputParameters& parameters);

protected:
	/// ADKernel objects must override precomputeQpResidual
	virtual ADRealVectorValue precomputeQpResidual() override;

	/// The variables which hold the value for K
	const Real &_thermal_conductivity
};