(module
  (memory (import "js" "mem") 1)
  ;; Swap two pointers in memory.
  (func $swapElem (param $mem1 i32) (param $mem2 i32)
    (local $intermediate i32)

    local.get $mem1
    i32.load
    local.set $intermediate
    
    local.get $mem1
    local.get $mem2
    i32.load
    i32.store

    local.get $mem2
    local.get $intermediate
    i32.store
  )

  (func $insertElem (param $p i32) (param $sortedSize i32) (param $pNext i32) (result i32)
    (local $elemPrior i32)
    (local $toInsert i32)
    
    (i32.eq (local.get $p) (local.get $pNext))
    (if
      (then 
        (return (local.get $sortedSize))
      )
    )
    (i32.load (local.get $pNext))
    local.set $toInsert

    local.get $p
    i32.const 4  ;; i32 size
    local.get $sortedSize
    i32.const 1  ;; 0 index correction
    i32.sub
    i32.mul
    i32.add
    local.set $elemPrior
    
    local.get $elemPrior
    i32.load 
    local.get $toInsert
    i32.lt_s
    (if (result i32)
      ;; stop here and store.
      (then
        local.get $p
        i32.const 4  ;; i32 size
        local.get $sortedSize
        i32.mul
        i32.add
        local.get $toInsert
        i32.store

        ;; Return the new position.
        local.get $sortedSize
        i32.const 1
        i32.add
      )
      ;; swap positions, recurse on the rest.
      (else
        (call $swapElem (local.get $elemPrior) (local.get $pNext))
        (call $insertElem
          (local.get $p)
          (i32.sub (local.get $sortedSize) (i32.const 1))
          (local.get $elemPrior)
        )
      )
    )
  )
  
  (func $sortArray (param $p i32) (param $size i32) (result i32)
    (local $sortedCount i32)
    (local $nextToSort i32)

    i32.const 1
    local.set $sortedCount
    (block $breakOut
      (loop $arrayLoop
        
        ;; Are we already sorted?
        local.get $sortedCount
        local.get $size
        i32.eq
        br_if $breakOut
        
        ;; Keep going!
        local.get $sortedCount
        i32.const 4  ;; i32 size
        i32.mul
        local.get $p
        i32.add
        local.set $nextToSort

        (call $insertElem
          (local.get $p)
          (local.get $sortedCount)
          (local.get $nextToSort)
        )

        local.get $sortedCount
        i32.const 1
        i32.add
        local.set $sortedCount

        br $arrayLoop
      )
    )
    local.get $sortedCount
  )
  
  (func $diffArray (param $ptr1 i32) (param $ptr2 i32) (param $size i32) (result i32)
    (local $acc i32)
    (local $pos i32)
    (local $posOffset i32)
    (local $arr1Pos i32)
    (local $arr1Val i32)
    (local $arr2Pos i32)
    (local $arr2Val i32)

    i32.const 0
    local.set $pos
    
    (block $breakOut
      (loop $arrayLoop
        local.get $pos
        i32.const 4  ;; i32 size
        i32.mul
        local.set $posOffset
        
        local.get $posOffset
        local.get $ptr1
        i32.add
        local.set $arr1Pos
        
        local.get $posOffset
        local.get $ptr2
        i32.add
        local.set $arr2Pos

        local.get $arr1Pos
        i32.load
        local.set $arr1Val
        local.get $arr2Pos
        i32.load
        local.set $arr2Val

        local.get $arr1Val
        local.get $arr2Val
        i32.lt_s

        (if (result i32)
          (then (i32.sub (local.get $arr2Val) (local.get $arr1Val)))
          (else (i32.sub (local.get $arr1Val) (local.get $arr2Val)))
        )
        
        local.get $acc
        i32.add
        local.set $acc

        local.get $pos
        i32.const 1
        i32.add
        local.set $pos

        local.get $pos
        local.get $size
        i32.eq
        br_if $breakOut

        br $arrayLoop
      )
    )
    
    local.get $acc
  )

  (func $main (param $ptr1 i32) (param $ptr2 i32) (param $len i32) (result i32)
    (local $sortedCount i32)
    (call $sortArray (local.get $ptr1) (local.get $len))
    local.set $sortedCount
    (call $sortArray (local.get $ptr2) (local.get $len))
    local.set $sortedCount
    (call $diffArray (local.get $ptr1) (local.get $ptr2) (local.get $len))
  )
  (export "main" (func $main))
)
