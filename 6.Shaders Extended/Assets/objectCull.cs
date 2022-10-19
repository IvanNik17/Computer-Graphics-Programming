using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class objectCull : MonoBehaviour
{

    [SerializeField]
    Transform cullerObj;


    // Update is called once per frame
    void Update()
    {
        Renderer renderer = GetComponent<Renderer>();

        Material material = renderer.sharedMaterial;

        material.SetMatrix("CullerShape", cullerObj.worldToLocalMatrix);
    }
}
