using UnityEngine;
public class GlitchCamera : MonoBehaviour
{
    public Material material;

    [Header("Glitch Settings")]
    public float glitchTime = 5.0f; // Total glitch effect time
    public float maxOffsetVariation = 0.2f; // Maximum color offset variation
    public float blurAmount = 0.0f; // Blur amount

    private bool isGlitchActive = false;
    private float glitchTimer = 0.0f;

    // Initial values
    private Vector2 redOffset = Vector2.zero;
    private Vector2 greenOffset = Vector2.zero;
    private Vector2 blueOffset = Vector2.zero;

    void Start()
    {
        if (material == null)
        {
            Debug.LogError("Material is not assigned!");
        }
    }

    void Update()
    {
        // Check for space bar press to start glitch effect
        if (Input.GetKeyDown(KeyCode.Space) && !isGlitchActive)
        {
            isGlitchActive = true;
            glitchTimer = glitchTime;
        }

        if (isGlitchActive)
        {
            if (glitchTimer > 0)
            {
                // Update glitch timer
                glitchTimer -= Time.deltaTime;
                float t = glitchTimer / glitchTime;
                float smoothT = Mathf.Sin(t * Mathf.PI);

                // Generate random values for offsets and blur amount with less variation
                redOffset = new Vector2(Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT, Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT);
                greenOffset = new Vector2(Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT, Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT);
                blueOffset = new Vector2(Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT, Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT);

                // Update material properties
                if (material != null)
                {
                    material.SetFloat("_RedX", redOffset.x);
                    material.SetFloat("_RedY", redOffset.y);
                    material.SetFloat("_GreenX", greenOffset.x);
                    material.SetFloat("_GreenY", greenOffset.y);
                    material.SetFloat("_BlueX", blueOffset.x);
                    material.SetFloat("_BlueY", blueOffset.y);
                    material.SetFloat("_BlurAmount", blurAmount);
                }
                else
                {
                    Debug.LogError("Material is not assigned!");
                }
            }
            else
            {
                // End of glitch effect
                isGlitchActive = false;
                // Reset values if desired
                if (material != null)
                {
                    material.SetFloat("_RedX", 0.0f);
                    material.SetFloat("_RedY", 0.0f);
                    material.SetFloat("_GreenX", 0.0f);
                    material.SetFloat("_GreenY", 0.0f);
                    material.SetFloat("_BlueX", 0.0f);
                    material.SetFloat("_BlueY", 0.0f);
                    material.SetFloat("_BlurAmount", 0.0f);
                }
                else
                {
                    Debug.LogError("Material is not assigned!");
                }
            }
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Debug.LogError("Material is not assigned in OnRenderImage!");
            Graphics.Blit(source, destination);
        }
    }
}


