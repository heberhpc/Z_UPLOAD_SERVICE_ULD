INTERFACE zif_data_ops_uld PUBLIC .
  TYPES: BEGIN OF ty_method_parameters,
           file_data  TYPE string,
           table_name TYPE string,
           db_action  TYPE string,
           has_header TYPE string,
         END OF ty_METHOD_PARAMETERS.

  TYPES: BEGIN OF ty_post_result_parameters,
           text        TYPE string,
           status_code TYPE i,
           reason      TYPE string,
         END OF ty_post_result_parameters.

  METHODS: process_post_upload IMPORTING VALUE(i_post_parameters) TYPE ty_method_parameters
                               RETURNING VALUE(r_result)          TYPE bapiret2.

ENDINTERFACE.
