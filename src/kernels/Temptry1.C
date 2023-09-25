#include "Temptry1.h"

registerMooseObject("BabblerApp", Temptry1);

InputParameters
Temptry1::validParams()
{
    InputParameters params = ADKernelGrad::validParams();
    params.addClassDescription("Compute the diffusion term for Temptry1 equation");
    params.addRequiredParam<Real>("thermal_conductivity", "The thermal_conductivity ($K$) of the medium.");
    return params;
}

Temptry1::Temptry1(const InputParameters& parameters)
    : ADKernelGrad(parameters),
    _thermal_conductivity(getParam<Real>("thermal_conductivity")),
{
}

ADRealVectorValue
Temptry1::precomputeQpResidual()
{
    return thermal_conductivity * _grad_Temperature[_qp];
}