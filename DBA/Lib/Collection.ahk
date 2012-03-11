#Include <Base>
/*
   Simple Collection Klasse
*/
class Collection
{
   ; Methoden Implementation
   /*
      Fügt ein Element der Collection hinzu
   */
   Add(obj){
      this.Insert(obj)
   }
   
   /*
      Fügt eine Auflistung dieser Collection hinzu
   */
   AddRange(objs){
      if(IsObject(objs)){
         for each, item in objs
            this.Insert(item)
      } else
         throw Exceptions.ArgumentException("Must submit Array!")
   }
   
   Clear(){
      this.Remove(this.MinIndex(), this.MaxIndex())   
   }
   
   RemoveItem(item){
      for k, e in this
         if(e = item)
            this.Remove(k)
   }
   
   /*
   Gibt die anzahl Elemente in dieser Collection zurück
   */
   Count(){
      i := 0
      for e in this ; zählt alle Elemente
         i++
      return i
   }
   
   /*
      Sortiert die Liste
   */
   Sort(comparer=""){
      if(IsFunc(comparer))
         comparer := "F " comparer
      
      for each, num in this
         nums .= num "`n"
      Sort, nums, % comparer
      this.Clear()
      Loop, parse, nums, `,
         this.Add(A_LoopField)
   }
   
   ToString(){
      str := ""
      for k, v in this
      {
         valStr := ""
         if(IsObject(v)){
            valStr := "{" . typeof(v) . "}"
            if(IsFunc(v.ToString)){
               valStr .= " " .  v.ToString()
            }
         }else{
            valStr := "'" v "'"
         }
         
         
         str .= k ": " . valStr . "`n"
      }
      return str
   }

   /*
      Konstruktor - erstellt eine neue, (leere) Collection
      
      enum : Element die zubign vorhanden sein sollen
   */
   __New(enum = 0){ 
      if(IsObject(enum)){
         this.AddRange(enum)
      }
   }
}