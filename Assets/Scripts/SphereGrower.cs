using UnityEngine;

public class SphereGrower : MonoBehaviour
{
    public Material growMaterial; 
    private Material originalMaterial; 
    private Renderer sphereRenderer; 
    private Vector3 originalScale; 
    private Vector3 targetScale; 

    private bool isGrowing = false; 
    public float growDuration = 1.0f; 
    public long growIterations = 1; 
    private long currentIteration = 0; 
    private float growTimer = 0.0f; 

    void Start()
    {
        sphereRenderer = GetComponent<Renderer>();
        originalMaterial = sphereRenderer.material;
        originalScale = transform.localScale;
        targetScale = originalScale * 20.0f; 
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.S) && currentIteration < growIterations)
        {
            currentIteration++;
            isGrowing = true;
            growTimer = 0.0f;
            sphereRenderer.material = growMaterial; 
        }

        if (isGrowing)
        {
            growTimer += Time.deltaTime;

            float t = growTimer / growDuration;
            t = Mathf.Clamp01(t); 

            transform.localScale = Vector3.Lerp(originalScale, targetScale, t);

            if (t >= 1.0f)
            {
                isGrowing = false;
            }
        }
    }
}

