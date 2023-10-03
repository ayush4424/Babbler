#include "Temptry1.h"

registerMooseObject("BabblerApp", Temptry1);

InputParameters
Temptry1::validParams()
{
    InputParameters params = ADKernel::validParams();
    params.addClassDescription("Compute the diffusion term for Temptry1 equation");
    params.addRequiredParam<Real>("thermal_conductivity", "The thermal_conductivity ($K$) of the medium.");
    params.addParam<Real>("heatsource", 0, "The heat stored per unit volume of the medium.");
    return params;
}

Temptry1::Temptry1(const InputParameters& parameters)
    : ADKernel(parameters),
    _thermal_conductivity(getParam<Real>("thermal_conductivity")),
    _heatsource(getParam<Real>("heatsource"))
{
}

ADReal
Temptry1::computeQpResidual()
{
    return - _thermal_conductivity * (_grad_test[_i][_qp] * _grad_u[_qp]) + _heatsource * _test[_i][_qp];
}