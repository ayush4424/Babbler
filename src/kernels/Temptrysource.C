#include "Temptrysource.h"

registerMooseObject("BabblerApp", Temptrysource);

InputParameters
Temptrysource::validParams()
{
    InputParameters params = ADKernel::validParams();
    params.addClassDescription("Compute the heat source term for Temptry equation");
    params.addRequiredParam<Real>("volumetric_heat", "The thermal_conductivity ($K$) of the medium.");
    return params;
}

Temptrysource::Temptrysource(const InputParameters& parameters)
    : ADKernel(parameters),
    _volumetric_heat(getParam<Real>("volumetric_heat"))
{
}

ADReal
Temptrysource::computeQpResidual()
{
    return - _volumetric_heat * _test[_i][_qp];
}