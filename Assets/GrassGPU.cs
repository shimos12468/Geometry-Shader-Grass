using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassGPU : MonoBehaviour
{
    [SerializeField] int resolution ;
    public float startHeight;
    [SerializeField] Vector2 size;
    [SerializeField] int seed;
    [SerializeField] Material grassMaterial;
    [SerializeField] Mesh grassMesh;
    

    private void OnEnable() {    
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Random.InitState(seed);
        List<Matrix4x4>matrecies = new List<Matrix4x4>(resolution);
        for(int i = 0;i<resolution;i++){
            Vector3 origin = transform.position;
            origin.y = startHeight;
            origin.x += size.x*Random.Range(-0.5f,0.5f);
            origin.z += size.y*Random.Range(-0.5f,0.5f);
            Ray ray = new Ray(origin ,Vector3.down);
            RaycastHit hit;
            if(Physics.Raycast(ray ,out hit)){
                origin = hit.point+(Vector3.one*0.5f);
                matrecies.Add(Matrix4x4.TRS(origin ,Quaternion.identity ,Vector3.one));
            }

        
        }
        Graphics.DrawMeshInstanced(grassMesh ,0,grassMaterial ,matrecies);
    }
}
