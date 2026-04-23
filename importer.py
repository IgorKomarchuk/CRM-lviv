import pandas as pd
import sqlite3 # Using sqlite for local demonstration, will be PostgreSQL on server

def import_excel_to_db(file_path):
    print(f"Starting import from {file_path}...")
    
    # Load the excel, skipping header rows to reach data
    try:
        df = pd.read_excel(file_path, skiprows=6)
        
        # Clean columns: we take only the relevant ones based on our mapping
        # Columns in Excel: Код, Артикул, Номенклатура, ..., Собівартість, Ціна продажі, Залишок, шт
        
        # Mapping to our DB fields
        mapping = {
            'Код': 'code_1c',
            'Артикул': 'sku',
            'Номенклатура': 'name_ua',
            'Собівартість.1': 'unit_cost_uah', # Note: pandas might rename duplicate column names
            'Ціна продажі': 'unit_price_uah',
            'Залишок, шт': 'stock_ua'
        }
        
        # In the provided excel, 'Собівартість' appeared twice, pandas adds .1 to the second one
        # Let's verify actual column names in the dataframe
        cols = df.columns.tolist()
        print("Detected columns:", cols)
        
        # Filter and rename
        # We find the index of columns to be safe
        final_data = []
        for index, row in df.iterrows():
            if pd.isna(row['Артикул']): continue # Skip empty rows
            
            product = {
                'sku': row['Артикул'],
                'code_1c': row['Код'],
                'name_ua': row['Номенклатура'],
                'unit_cost_uah': row[8], # Index-based to be sure (Собівартість unit)
                'unit_price_uah': row[9], # Ціна продажі
                'stock_ua': row[10]       # Залишок
            }
            final_data.append(product)
            
        print(f"Successfully processed {len(final_data)} products.")
        return final_data

    except Exception as e:
        print(f"Error during import: {e}")
        return None

if __name__ == "__main__":
    data = import_excel_to_db("d:/crm Lviv/sheet 1.xlsx")
    if data:
        print("Preview of imported data (first 2):")
        for p in data[:2]:
            print(p)
