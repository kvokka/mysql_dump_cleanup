## MysqlDumpCleanup

CLI tool for hiding some data in MySQL dump in sql format. syntax

```
    mysql_dump_cleanup dump_path fields_hash
      
      fields_hash must have one of the following formats 

      "{
        { remove_tables: [ :table_name1, :table_name2, etc ] },
        { remove_columns: { table_name1: [:column1, :column2,  etc] } },
        { xor_integer_columns: { table_name1: [:column1, :column2,  etc] } }
      }"

    remove_columns, remove_tables and xor_integer_columns and optional, so you may remove
    any of this options

    note, that you has to provide symbols in hash.
```

and puts the output to `clean.sql` file.

`xor_integer_columns` generate 8 digts random integer and XOR all fields with it.
works with Integer only now.


### License

This project rocks and uses MIT-LICENSE.
