using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour
{



    // Start is called before the first frame update
    void Start()
    {
        int x = 1;
        int y;
        Debug.Log($"Initial value {x}");
        int result = addVals( x, out y);

        

        Debug.Log($"End value {result}");
        Debug.Log($"End value of y {y}");
    }



    // int addVals(int x)
    // {
    //     return x+1;
    // }

    // void addVals(ref int x)
    // {
    //     x= x+1;
    // }

    int addVals(int x, out int y)
    {
        y = x;
        return x+1;
    }



}
