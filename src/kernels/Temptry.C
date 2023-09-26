#include "Temptry.h"

registerMooseObject("BabblerApp", Temptry);

InputParameters
Temptry::validParams()
{
    InputParameters params = ADKernelGrad::validParams();
    params.addClassDescription("Compute the diffusion term for Temptry equation");
    params.addRequiredParam<Real>("thermal_conductivity", "The thermal_conductivity ($K$) of the medium.");
    return params;
}

Temptry::Temptry(const InputParameters& parameters)
    : ADKernelGrad(parameters),
    _thermal_conductivity(getParam<Real>("thermal_conductivity"))
{
}

ADRealVectorValue
Temptry::precomputeQpResidual()
{
    return _thermal_conductivity * _grad_u[_qp];
}