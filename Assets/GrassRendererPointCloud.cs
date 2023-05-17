using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class GrassRendererPointCloud : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField, Range(1, 60000)] int resolution;
    public float startHeight;
    [SerializeField] Vector2 size;
    [SerializeField] int seed;
    public float offset = 0.5f;

    private Mesh mesh;
    public MeshFilter filter;
    List<Matrix4x4> matrecies;
    Vector3 lastPosition;
    List<Vector3> _Positions = new List<Vector3>();
    List<Color> _PointColor = new List<Color>();
    List<Vector3> normals = new List<Vector3>();
   private void OnEnable() {
    
   }
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

        if (lastPosition != transform.position)
        {
            lastPosition = transform.position;
            Debug.Log("sadasd");
            Random.InitState(seed);

            int[] indcies = new int[resolution];
            for (int i = 0; i < resolution; i++)
            {
                Vector3 origin = transform.position;
                origin.y = startHeight;
                origin.x += size.x * Random.Range(-0.5f, 0.5f);
                origin.z += size.y * Random.Range(-0.5f, 0.5f);
                Ray ray = new Ray(origin, Vector3.down);
                RaycastHit hit;
                if (Physics.Raycast(ray, out hit))
                {
                    origin = hit.point;
                    origin.y += offset;
                    _Positions.Add(origin);
                    _PointColor.Add(new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1));
                    indcies[i] = i;
                    normals.Add(hit.normal);
                }


            }

            mesh = new Mesh();
            mesh.SetVertices(_Positions);
            mesh.SetIndices(indcies, MeshTopology.Points, 0);
            mesh.SetColors(_PointColor);
            mesh.SetNormals(normals);
            filter.mesh = mesh;
            _PointColor.Clear();
            _Positions.Clear();
            normals.Clear();
        }

    }
}
