using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NightVisionController : MonoBehaviour
{
    public Material nightVisionMaterial; // Assign the night vision material in the Inspector

    private bool isNightVisionActive = false;
    private float transitionProgress = 0.0f;
    private float transitionDuration = 3.0f; // 3 seconds

    void Update()
    {
        // Check for input to toggle night vision
        if (Input.GetKeyDown(KeyCode.O))
        {
            isNightVisionActive = !isNightVisionActive;
            transitionProgress = 0.0f; // Reset transition progress
        }

        // Increment or decrement transition progress based on night vision activation
        if (isNightVisionActive && transitionProgress < transitionDuration)
        {
            transitionProgress += Time.deltaTime;
        }
        else if (!isNightVisionActive && transitionProgress > 0.0f)
        {
            transitionProgress -= Time.deltaTime;
        }

        // Clamp transition progress to ensure it stays within [0, transitionDuration]
        transitionProgress = Mathf.Clamp(transitionProgress, 0, transitionDuration);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (nightVisionMaterial != null)
        {
            // Calculate transition factor based on transition progress and duration
            float transitionFactor = Mathf.SmoothStep(0.0f, 1.0f, transitionProgress / transitionDuration);
            nightVisionMaterial.SetFloat("_TransitionFactor", transitionFactor);
            Graphics.Blit(src, dest, nightVisionMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}

