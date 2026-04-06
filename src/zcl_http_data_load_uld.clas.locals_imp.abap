*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


**********************************************************************
CLASS lcl__handler_ztcidades_ibge DEFINITION.

  PUBLIC SECTION.
    INTERFACES: zif_data_ops_uld.

    TYPES: tt_ibge_cities TYPE STANDARD TABLE OF ztcidades_ibge WITH EMPTY KEY.

    METHODS: parse_data_municipios IMPORTING VALUE(i_parameters)     TYPE zif_data_ops_uld=>ty_method_parameters
                                   RETURNING VALUE(t_ztcidades_ibge) TYPE tt_ibge_cities.


ENDCLASS.
CLASS lcl__handler_ztcidades_ibge IMPLEMENTATION.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD zif_data_ops_uld~process_post_upload.


    " Normalize Action Name
    DATA(lv_action) = to_upper( i_post_parameters-db_action ).

    CASE lv_action.

      WHEN 'CREATE'.
        r_result = VALUE #( type = 'E' message = 'Operação não Implementada para ZTCIDADES_IBGE' ).
        RETURN.

      WHEN 'UPDATE'.
        r_result = VALUE #( type = 'E' message = 'Operação não Implementada para ZTCIDADES_IBGE' ).
        RETURN.

      WHEN 'DELETE'.
        r_result = VALUE #( type = 'E' message = 'Operação não Implementada para ZTCIDADES_IBGE' ).
        RETURN.

      WHEN 'RESET'.
        r_result = VALUE #( type = 'E' message = 'Operação não Implementada para ZTCIDADES_IBGE' ).
        RETURN.

      WHEN OTHERS.
        r_result = VALUE #( type = 'E' message = 'Operação não Implementada para ZTCIDADES_IBGE' ).
        RETURN.

    ENDCASE.


  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD parse_data_municipios.




  ENDMETHOD.

ENDCLASS.


**********************************************************************
