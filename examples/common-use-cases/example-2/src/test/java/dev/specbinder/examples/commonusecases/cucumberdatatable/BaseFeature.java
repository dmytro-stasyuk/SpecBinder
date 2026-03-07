package dev.specbinder.examples.commonusecases.cucumberdatatable;

import dev.specbinder.annotations.Feature2JUnitOptions;

import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;

/**
 * Base class configuring CUCUMBER_DATA_TABLE mode.
 * All marker classes extending this will receive DataTable parameters
 * instead of the default LIST_OF_OBJECT_PARAMS.
 */
@Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
public abstract class BaseFeature {
}
