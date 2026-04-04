*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


**********************************************************************
CLASS lcl__handler_ztcidades_ibge DEFINITION.

  PUBLIC SECTION.
    INTERFACES: zif_data_ops_uld.

ENDCLASS.
CLASS lcl__handler_ztcidades_ibge IMPLEMENTATION.

  METHOD zif_data_ops_uld~process_post_upload.
    r_result-type = 'E'.
    r_result-message = 'Erro Teste'.
  ENDMETHOD.

ENDCLASS.


**********************************************************************
