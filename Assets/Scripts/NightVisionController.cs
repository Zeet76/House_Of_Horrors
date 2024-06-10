using UnityEngine;

public class NightVisionController : MonoBehaviour
{
    // The material to be used for night vision effect
    public Material nightVisionMaterial; 

    // Flag to check if night vision is active
    private bool isNightVisionActive = false;

    // Variables to control the transition of the night vision effect
    private float transitionProgress = 0.0f;
    private float transitionDuration = 3.0f; 

    void Update()
    {
        // Check if the 'O' key is pressed
        if (Input.GetKeyDown(KeyCode.O))
        {
            // Toggle the night vision active state
            isNightVisionActive = !isNightVisionActive;

            // Reset the transition progress based on the night vision state
            transitionProgress = isNightVisionActive ? transitionDuration : 0.0f; 
        }

        // Update the transition progress based on the night vision state
        UpdateTransitionProgress();
    }

    // Method to update the transition progress
    private void UpdateTransitionProgress()
    {
        // If night vision is active and transition is not complete, decrease the progress
        if (isNightVisionActive && transitionProgress > 0.0f)
        {
            transitionProgress -= Time.deltaTime;
        }
        // If night vision is not active and transition is not complete, increase the progress
        else if (!isNightVisionActive && transitionProgress < transitionDuration)
        {
            transitionProgress += Time.deltaTime;
        }

        // Clamp the transition progress to ensure it stays within [0, transitionDuration]
        transitionProgress = Mathf.Clamp(transitionProgress, 0, transitionDuration);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // If the night vision material is assigned
        if (nightVisionMaterial != null)
        {
            // Calculate the transition factor
            float transitionFactor = Mathf.SmoothStep(-0.1f, 1.1f, transitionProgress / transitionDuration);

            // Set the transition factor in the material
            nightVisionMaterial.SetFloat("_TransitionFactor", transitionFactor);

            // Apply the material to the source texture and output to the destination texture
            Graphics.Blit(src, dest, nightVisionMaterial);
        }
        else
        {
            // If no night vision material is assigned, just copy the source texture to the destination
            Graphics.Blit(src, dest);
        }
    }
}
